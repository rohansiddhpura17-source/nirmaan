#!/usr/bin/env node
/**
 * CLI Script to Seed Realistic Business Data
 *
 * Usage:
 *   node backend/src/scripts/seedBusinessData.js [businessId] [ownerId]
 */

const seedService = require('../services/seedService');

async function main() {
  const businessId = process.argv[2] || 'biz_nirmaan_demo';
  const ownerId = process.argv[3] || 'usr_business_owner';

  console.log('====================================================');
  console.log(`🌱 Seeding Realistic Business Data for Tenant: ${businessId}`);
  console.log('====================================================');

  try {
    const summary = await seedService.seedTenant(businessId, ownerId);
    console.log('\n✅ Successfully seeded business data:');
    console.log(`   - Business:  ${summary.businessName} (${summary.businessId})`);
    console.log(`   - Products:  ${summary.productsCount} (Grocery, Beverages, Personal Care, Household)`);
    console.log(`   - Customers: ${summary.customersCount} (Active, with Khata & order history)`);
    console.log(`   - Orders:    ${summary.ordersCount} (Distributed over today, yesterday, 7d, 30d)`);
    console.log('   - Includes ord_1003 (status PENDING) for testing order cancellation flow');
    console.log('====================================================\n');
    process.exit(0);
  } catch (err) {
    console.error('❌ Failed to seed business data:', err);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}
