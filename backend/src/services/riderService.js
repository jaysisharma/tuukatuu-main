const Rider = require('../models/Rider');
const Order = require('../models/Order');
const User = require('../models/User');
const logger = require('../utils/logger');

class RiderService {
  // Find nearby available riders
  async findNearbyRiders(pickupLocation, maxDistance = 5, maxRiders = 10) {
    try {
      const { longitude, latitude } = pickupLocation;
      
      const riders = await Rider.find({
        'currentLocation.coordinates': {
          $near: {
            $geometry: {
              type: 'Point',
              coordinates: [longitude, latitude]
            },
            $maxDistance: maxDistance * 1000 // Convert km to meters
          }
        },
        'status': { $in: ['online', 'available'] },
        'workPreferences.isAvailable': true,
        'verification.isApproved': true,
        'currentAssignment.orderId': { $exists: false } // Not currently assigned
      })
      .populate('userId', 'name phone')
      .limit(maxRiders)
      .sort({ 'performance.averageRating': -1 }); // Prioritize higher rated riders

      return riders;
    } catch (error) {
      logger.error('Error finding nearby riders:', error);
      throw error;
    }
  }

  // Assign order to best available rider
  async assignOrderToRider(orderId, pickupLocation) {
    try {
      const order = await Order.findById(orderId);
      if (!order) {
        throw new Error('Order not found');
      }

      if (order.riderId) {
        throw new Error('Order already assigned to a rider');
      }

      // Find nearby riders
      const nearbyRiders = await this.findNearbyRiders(pickupLocation, 5, 5);
      
      if (nearbyRiders.length === 0) {
        throw new Error('No available riders nearby');
      }

      // Select the best rider based on:
      // 1. Rating
      // 2. Completion rate
      // 3. Distance
      const bestRider = this.selectBestRider(nearbyRiders, pickupLocation);

      // Assign order to rider
      order.riderId = bestRider._id;
      order.status = 'picked_up';
      order.statusHistory.push({
        status: 'picked_up',
        updatedBy: bestRider._id,
        timestamp: new Date()
      });

      // Update rider assignment
      bestRider.currentAssignment = {
        orderId: order._id,
        assignedAt: new Date(),
        pickupLocation: order.pickupLocation,
        deliveryLocation: order.deliveryAddress
      };
      bestRider.status = 'on_delivery';

      await Promise.all([order.save(), bestRider.save()]);

      return { order, rider: bestRider };
    } catch (error) {
      logger.error('Error assigning order to rider:', error);
      throw error;
    }
  }

  // Select best rider from available riders
  selectBestRider(riders, pickupLocation) {
    return riders.reduce((best, current) => {
      const bestScore = this.calculateRiderScore(best, pickupLocation);
      const currentScore = this.calculateRiderScore(current, pickupLocation);
      return currentScore > bestScore ? current : best;
    });
  }

  // Calculate rider score for assignment
  calculateRiderScore(rider, pickupLocation) {
    const { longitude, latitude } = pickupLocation;
    const riderLng = rider.currentLocation.coordinates[0];
    const riderLat = rider.currentLocation.coordinates[1];
    
    // Calculate distance
    const distance = this.calculateDistance(latitude, longitude, riderLat, riderLng);
    
    // Calculate score based on:
    // - Rating (40% weight)
    // - Completion rate (30% weight)
    // - Distance (20% weight)
    // - On-time delivery rate (10% weight)
    
    const ratingScore = (rider.performance.averageRating / 5) * 0.4;
    const completionRate = rider.performance.totalDeliveries > 0 
      ? (rider.performance.completedDeliveries / rider.performance.totalDeliveries) * 0.3
      : 0;
    const distanceScore = Math.max(0, (5 - distance) / 5) * 0.2;
    const onTimeRate = rider.performance.completedDeliveries > 0
      ? (rider.performance.onTimeDeliveries / rider.performance.completedDeliveries) * 0.1
      : 0;

    return ratingScore + completionRate + distanceScore + onTimeRate;
  }

  // Calculate distance between two points
  calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Radius of the earth in km
    const dLat = this.deg2rad(lat2 - lat1);
    const dLon = this.deg2rad(lon2 - lon1);
    const a = 
      Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(this.deg2rad(lat1)) * Math.cos(this.deg2rad(lat2)) * 
      Math.sin(dLon/2) * Math.sin(dLon/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    const d = R * c; // Distance in km
    return d;
  }

  deg2rad(deg) {
    return deg * (Math.PI/180);
  }

  // Update rider earnings after delivery
  async updateRiderEarnings(riderId, orderId) {
    try {
      const order = await Order.findById(orderId);
      const rider = await Rider.findById(riderId);

      if (!order || !rider) {
        throw new Error('Order or rider not found');
      }

      const deliveryFee = order.deliveryFee || 50;
      const tip = order.tip || 0;
      const totalEarning = deliveryFee + tip;

      // Update earnings
      rider.earnings.totalEarnings += totalEarning;
      rider.earnings.thisWeek += totalEarning;
      rider.earnings.thisMonth += totalEarning;
      rider.earnings.walletBalance += totalEarning;

      // Update performance
      rider.performance.totalDeliveries += 1;
      rider.performance.completedDeliveries += 1;

      // Check if delivery was on time (within 30 minutes of estimated time)
      const estimatedDeliveryTime = rider.currentAssignment.estimatedDeliveryTime;
      const actualDeliveryTime = new Date();
      const timeDifference = Math.abs(actualDeliveryTime - estimatedDeliveryTime) / (1000 * 60); // in minutes

      if (timeDifference <= 30) {
        rider.performance.onTimeDeliveries += 1;
      } else {
        rider.performance.lateDeliveries += 1;
      }

      // Clear current assignment
      rider.currentAssignment = {};
      rider.status = 'online';

      await rider.save();

      return {
        totalEarning,
        deliveryFee,
        tip,
        newBalance: rider.earnings.walletBalance
      };
    } catch (error) {
      logger.error('Error updating rider earnings:', error);
      throw error;
    }
  }

  // Calculate rider earnings for different periods
  async calculateEarnings(riderId, period = 'all', startDate = null, endDate = null) {
    try {
      const rider = await Rider.findById(riderId);
      if (!rider) {
        throw new Error('Rider not found');
      }

      let query = { riderId, status: 'delivered' };
      let dateRange = {};

      switch (period) {
        case 'today':
          const today = new Date();
          today.setHours(0, 0, 0, 0);
          const tomorrow = new Date(today);
          tomorrow.setDate(tomorrow.getDate() + 1);
          dateRange = { $gte: today, $lt: tomorrow };
          break;
        case 'week':
          const startOfWeek = new Date();
          startOfWeek.setDate(startOfWeek.getDate() - startOfWeek.getDay());
          startOfWeek.setHours(0, 0, 0, 0);
          dateRange = { $gte: startOfWeek };
          break;
        case 'month':
          const startOfMonth = new Date();
          startOfMonth.setDate(1);
          startOfMonth.setHours(0, 0, 0, 0);
          dateRange = { $gte: startOfMonth };
          break;
        case 'custom':
          if (startDate && endDate) {
            dateRange = { $gte: new Date(startDate), $lte: new Date(endDate) };
          }
          break;
      }

      if (Object.keys(dateRange).length > 0) {
        query.updatedAt = dateRange;
      }

      const orders = await Order.find(query);
      
      const earnings = {
        total: 0,
        deliveryFees: 0,
        tips: 0,
        orders: orders.length,
        breakdown: []
      };

      orders.forEach(order => {
        const deliveryFee = order.deliveryFee || 50;
        const tip = order.tip || 0;
        const total = deliveryFee + tip;

        earnings.total += total;
        earnings.deliveryFees += deliveryFee;
        earnings.tips += tip;
        earnings.breakdown.push({
          orderId: order._id,
          date: order.updatedAt,
          deliveryFee,
          tip,
          total
        });
      });

      return earnings;
    } catch (error) {
      logger.error('Error calculating earnings:', error);
      throw error;
    }
  }

  // Get rider performance statistics
  async getPerformanceStats(riderId) {
    try {
      const rider = await Rider.findById(riderId);
      if (!rider) {
        throw new Error('Rider not found');
      }

      const performance = rider.performance;
      const totalDeliveries = performance.totalDeliveries;
      const completedDeliveries = performance.completedDeliveries;
      const cancelledDeliveries = performance.cancelledDeliveries;

      const stats = {
        totalDeliveries,
        completedDeliveries,
        cancelledDeliveries,
        completionRate: totalDeliveries > 0 ? (completedDeliveries / totalDeliveries * 100).toFixed(1) : 0,
        cancellationRate: totalDeliveries > 0 ? (cancelledDeliveries / totalDeliveries * 100).toFixed(1) : 0,
        averageRating: performance.averageRating.toFixed(1),
        totalReviews: performance.totalReviews,
        onTimeDeliveries: performance.onTimeDeliveries,
        lateDeliveries: performance.lateDeliveries,
        onTimeRate: completedDeliveries > 0 ? (performance.onTimeDeliveries / completedDeliveries * 100).toFixed(1) : 0
      };

      return stats;
    } catch (error) {
      logger.error('Error getting performance stats:', error);
      throw error;
    }
  }

  // Update rider rating
  async updateRiderRating(riderId, orderId, rating, review = '') {
    try {
      const rider = await Rider.findById(riderId);
      if (!rider) {
        throw new Error('Rider not found');
      }

      if (rating < 1 || rating > 5) {
        throw new Error('Rating must be between 1 and 5');
      }

      const currentRating = rider.performance.averageRating;
      const currentReviews = rider.performance.totalReviews;

      // Calculate new average rating
      const newAverageRating = ((currentRating * currentReviews) + rating) / (currentReviews + 1);

      rider.performance.averageRating = newAverageRating;
      rider.performance.totalReviews = currentReviews + 1;

      await rider.save();

      return {
        newAverageRating: newAverageRating.toFixed(1),
        totalReviews: rider.performance.totalReviews
      };
    } catch (error) {
      logger.error('Error updating rider rating:', error);
      throw error;
    }
  }

  // Get rider analytics
  async getRiderAnalytics(riderId, period = 'month') {
    try {
      const rider = await Rider.findById(riderId);
      if (!rider) {
        throw new Error('Rider not found');
      }

      let startDate;
      switch (period) {
        case 'week':
          startDate = new Date();
          startDate.setDate(startDate.getDate() - 7);
          break;
        case 'month':
          startDate = new Date();
          startDate.setMonth(startDate.getMonth() - 1);
          break;
        case 'year':
          startDate = new Date();
          startDate.setFullYear(startDate.getFullYear() - 1);
          break;
        default:
          startDate = new Date();
          startDate.setMonth(startDate.getMonth() - 1);
      }

      const orders = await Order.find({
        riderId,
        status: 'delivered',
        updatedAt: { $gte: startDate }
      });

      const analytics = {
        period,
        totalOrders: orders.length,
        totalEarnings: 0,
        averageOrderValue: 0,
        dailyStats: {},
        hourlyStats: {},
        topAreas: {},
        performance: {
          onTimeDeliveries: 0,
          lateDeliveries: 0,
          averageRating: 0
        }
      };

      orders.forEach(order => {
        const deliveryFee = order.deliveryFee || 50;
        const tip = order.tip || 0;
        const total = deliveryFee + tip;

        analytics.totalEarnings += total;

        // Daily stats
        const day = order.updatedAt.toDateString();
        if (!analytics.dailyStats[day]) {
          analytics.dailyStats[day] = { orders: 0, earnings: 0 };
        }
        analytics.dailyStats[day].orders += 1;
        analytics.dailyStats[day].earnings += total;

        // Hourly stats
        const hour = order.updatedAt.getHours();
        if (!analytics.hourlyStats[hour]) {
          analytics.hourlyStats[hour] = { orders: 0, earnings: 0 };
        }
        analytics.hourlyStats[hour].orders += 1;
        analytics.hourlyStats[hour].earnings += total;

        // Area stats
        const area = order.deliveryAddress.split(',')[0]; // Simple area extraction
        if (!analytics.topAreas[area]) {
          analytics.topAreas[area] = { orders: 0, earnings: 0 };
        }
        analytics.topAreas[area].orders += 1;
        analytics.topAreas[area].earnings += total;
      });

      if (orders.length > 0) {
        analytics.averageOrderValue = analytics.totalEarnings / orders.length;
      }

      // Convert to arrays for easier frontend consumption
      analytics.dailyStats = Object.entries(analytics.dailyStats).map(([date, stats]) => ({
        date,
        ...stats
      }));

      analytics.hourlyStats = Object.entries(analytics.hourlyStats).map(([hour, stats]) => ({
        hour: parseInt(hour),
        ...stats
      }));

      analytics.topAreas = Object.entries(analytics.topAreas)
        .map(([area, stats]) => ({ area, ...stats }))
        .sort((a, b) => b.orders - a.orders)
        .slice(0, 5);

      return analytics;
    } catch (error) {
      logger.error('Error getting rider analytics:', error);
      throw error;
    }
  }
}

module.exports = new RiderService(); 