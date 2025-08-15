const express = require('express');
const User = require('../models/User');
const { sortAndShuffleByDistance, fisherYatesShuffle } = require('../utils/shuffleUtils');

const router = express.Router();

const DISTANCE_GROUPS = [1, 3, 5, 10]; // km

/**
 * Fetch vendors by type, with optional distance sorting/shuffling
 */
const getVendorsByType = async (vendorType, req, res) => {
    try {
        const { lat, lon } = req.query;

        let vendors = await User.find({
            role: 'vendor',
            vendorType
        })
            .select('-password')
            .lean(); // Improves performance

        if (lat && lon) {
            const userLat = parseFloat(lat);
            const userLon = parseFloat(lon);

            if (isNaN(userLat) || isNaN(userLon)) {
                return res.status(400).json({ message: 'Invalid coordinates provided' });
            }

            vendors = sortAndShuffleByDistance(vendors, userLat, userLon, {
                distanceGroups: DISTANCE_GROUPS,
                shuffleWithinGroups: true,
                prioritizeFeatured: true
            });
        } else {
            // Always shuffle when no coordinates provided for variety
            vendors = fisherYatesShuffle(vendors);
        }

        res.json(vendors);
    } catch (error) {
        console.error(`Error fetching ${vendorType}s:`, error);
        res.status(500).json({ message: `Failed to fetch ${vendorType}s` });
    }
};

const getNearbyFeaturedStores = async (req, res) => {
    try {
        const { lat, lon, maxDistanceKm } = req.query;
        console.log('📍 Featured Stores API called with coordinates:', { lat, lon, maxDistanceKm });

        if (!lat || !lon) {
            console.log('❌ Missing coordinates in request');
            return res.status(400).json({ message: 'Latitude and longitude are required' });
        }

        const latitude = parseFloat(lat);
        const longitude = parseFloat(lon);
        if (isNaN(latitude) || isNaN(longitude)) {
            console.log('❌ Invalid coordinates:', { lat, lon, parsedLat: latitude, parsedLon: longitude });
            return res.status(400).json({ message: 'Invalid coordinates' });
        }

        // maxDistance in meters (default 10km)
        const maxDistanceMeters = maxDistanceKm ? parseFloat(maxDistanceKm) * 1000 : 10000;

        if (isNaN(maxDistanceMeters)) {
            console.log('❌ Invalid maxDistanceKm:', maxDistanceKm);
            return res.status(400).json({ message: 'Invalid maxDistanceKm' });
        }

        console.log('📍 Searching for stores near:', { latitude, longitude, maxDistanceMeters });

        // First try to find featured stores
        let vendors = await User.aggregate([
            {
                $geoNear: {
                    near: { type: 'Point', coordinates: [longitude, latitude] },
                    distanceField: 'distance',
                    spherical: true,
                    maxDistance: maxDistanceMeters,
                    query: { role: 'vendor', vendorType: 'store', isFeatured: true }
                }
            },
            {
                $project: {
                    password: 0,  // exclude password
                    storeCoordinates: 0 // optional to exclude if not needed
                }
            },
            {
                $sort: { distance: 1 }
            }
        ]);
        
        console.log('📍 Found ${vendors.length} featured stores');
        
        // If no featured stores found, get all stores
        if (vendors.length === 0) {
            console.log('📍 No featured stores found, getting all stores...');
            vendors = await User.aggregate([
                {
                    $geoNear: {
                        near: { type: 'Point', coordinates: [longitude, latitude] },
                        distanceField: 'distance',
                        spherical: true,
                        maxDistance: maxDistanceMeters,
                        query: { role: 'vendor', vendorType: 'store' }
                    }
                },
                {
                    $project: {
                    password: 0,  // exclude password
                    storeCoordinates: 0 // optional to exclude if not needed
                }
                },
                {
                    $sort: { distance: 1 }
                }
            ]);
            console.log('📍 Found ${vendors.length} total stores');
        }
        
        // Always shuffle the results for variety, even when sorted by distance
        vendors = fisherYatesShuffle(vendors);
        
        console.log('📍 Returning ${vendors.length} stores');
        res.json(vendors);
    } catch (error) {
        console.error('❌ Error fetching nearby stores:', error);
        res.status(500).json({ message: 'Failed to fetch nearby stores' });
    }
};


const getNearbyFeaturedRestaurants = async (req, res) => {
    try {
        const { lat, lon } = req.query;
        console.log('📍 Featured Restaurants API called with coordinates:', { lat, lon });
        
        if (!lat || !lon) {
            console.log('❌ Missing coordinates in request');
            return res.status(400).json({ message: 'Latitude and longitude are required' });
        }
        
        const maxDistanceKm = 10; // Default 10km
        const latitude = parseFloat(lat);
        const longitude = parseFloat(lon);
        
        if (isNaN(latitude) || isNaN(longitude)) {
            console.log('❌ Invalid coordinates:', { lat, lon, parsedLat: latitude, parsedLon: longitude });
            return res.status(400).json({ message: 'Invalid coordinates' });
        }

        console.log('📍 Searching for featured restaurants near:', { latitude, longitude, maxDistanceKm });

        // maxDistance in meters (default 10km)
        const maxDistanceMeters = maxDistanceKm * 1000;

        let vendors = [];
        
        try {
            // First try to find featured restaurants
            vendors = await User.aggregate([
                {
                    $geoNear: {
                        near: { type: 'Point', coordinates: [longitude, latitude] },
                        distanceField: 'distance',
                        spherical: true,
                        maxDistance: maxDistanceMeters,
                        query: { role: 'vendor', vendorType: 'restaurant', isFeatured: true }
                    }
                },
                {
                    $project: {
                        password: 0,  // exclude password
                        storeCoordinates: 0 // optional to exclude if not needed
                    }
                },
                {
                    $sort: { distance: 1 }
                }
            ]);
            
            console.log(`📍 Found ${vendors.length} featured restaurants`);
        } catch (geoError) {
            console.log('⚠️ GeoNear query failed, trying fallback:', geoError.message);
            
            // Fallback: simple find query without geoNear
            vendors = await User.find({
                role: 'vendor',
                vendorType: 'restaurant',
                isFeatured: true
            }).select('-password -storeCoordinates').limit(10);
            
            console.log(`📍 Fallback query found ${vendors.length} featured restaurants`);
        }
        
        // If no featured restaurants found, fall back to regular restaurants
        if (vendors.length === 0) {
            console.log('📍 No featured restaurants found, falling back to regular restaurants');
            try {
                vendors = await User.aggregate([
                    {
                        $geoNear: {
                            near: { type: 'Point', coordinates: [longitude, latitude] },
                            distanceField: 'distance',
                            spherical: true,
                            maxDistance: maxDistanceMeters,
                            query: { role: 'vendor', vendorType: 'restaurant' }
                        }
                    },
                    {
                        $project: {
                            password: 0,  // exclude password
                            storeCoordinates: 0 // optional to exclude if not needed
                        }
                    },
                    {
                        $sort: { distance: 1 }
                    }
                ]);
            } catch (fallbackError) {
                console.log('⚠️ Fallback geoNear also failed, using simple find:', fallbackError.message);
                vendors = await User.find({
                    role: 'vendor',
                    vendorType: 'restaurant'
                }).select('-password -storeCoordinates').limit(10);
            }
        }
        
        // Always shuffle the results for variety, even when sorted by distance
        vendors = fisherYatesShuffle(vendors);
        
        console.log(`📍 Total restaurants found: ${vendors.length}`);
        res.json(vendors);
    } catch (error) {
        console.error('❌ Error fetching nearby featured vendors:', error);
        res.status(500).json({ message: 'Failed to fetch nearby featured vendors' });
    }
};


// Routes
router.get('/all-stores', (req, res) => getVendorsByType('store', req, res));
router.get('/all-restaurants', (req, res) => getVendorsByType('restaurant', req, res));
router.get('/featured-stores', (req, res) => getNearbyFeaturedStores(req, res));
router.get('/featured-restaurants', (req, res) => getNearbyFeaturedRestaurants(req, res));

module.exports = router;
