'use strict';

/**
 * user-favorite service
 */

const { createCoreService } = require('@strapi/strapi').factories;

module.exports = createCoreService('api::user-favorite.user-favorite');
