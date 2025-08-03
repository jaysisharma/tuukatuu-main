const mongoose = require('mongoose');

const comboSchema = new mongoose.Schema({
  name: { type: String, required: true },
  products: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true }],
  price: { type: Number, required: true },
  image: { type: String },
  tags: [{ type: String }],
  isActive: { type: Boolean, default: true },
}, { timestamps: true });

comboSchema.statics.seedCombos = async function() {
  const Product = require('./Product');
  // Find some products by name for combos
  const apple = await Product.findOne({ name: /apple/i });
  const bread = await Product.findOne({ name: /bread/i });
  const milk = await Product.findOne({ name: /milk/i });
  const chips = await Product.findOne({ name: /chip/i });
  const coke = await Product.findOne({ name: /coca|coke/i });
  const cake = await Product.findOne({ name: /cake/i });
  const burger = await Product.findOne({ name: /burger/i });
  const wine = await Product.findOne({ name: /wine/i });
  const combos = [
    {
      name: 'Breakfast Combo',
      products: [apple?._id, bread?._id, milk?._id].filter(Boolean),
      price: 199,
      image: '',
      tags: ['Essentials', 'Morning'],
      isActive: true,
    },
    {
      name: 'Party Night Pack',
      products: [chips?._id, coke?._id, cake?._id, wine?._id].filter(Boolean),
      price: 499,
      image: '',
      tags: ['Party', 'Night'],
      isActive: true,
    },
    {
      name: 'Burger & Coke Combo',
      products: [burger?._id, coke?._id].filter(Boolean),
      price: 299,
      image: '',
      tags: ['Fast Food'],
      isActive: true,
    },
  ];
  await this.deleteMany({});
  await this.insertMany(combos);
};

module.exports = mongoose.model('Combo', comboSchema); 