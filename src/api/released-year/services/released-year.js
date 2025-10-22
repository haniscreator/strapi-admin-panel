'use strict';

/**
 * released-year service
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::released-year.released-year');
