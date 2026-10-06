/**
 * AI Controller for Nirmaan (Phase 8).
 *
 * Handles HTTP requests for:
 * - POST /api/v1/ai/coach (Natural-language AI Business Coach)
 * - GET  /api/v1/ai/daily-brief (Today's Business AI Executive Briefing)
 */

const aiService = require('../services/aiService');

class AiController {
  constructor(service = aiService) {
    this.aiService = service;
  }

  /**
   * Handle user business questions to the AI Coach.
   */
  async askCoach(req, res, next) {
    try {
      const businessId = req.businessId;
      if (!businessId) {
        return res.status(400).json({
          success: false,
          message: 'Business ID is required in authenticated session',
          error: 'MISSING_BUSINESS_ID',
        });
      }

      const { question, history } = req.body || {};
      if (!question || typeof question !== 'string' || question.trim().length === 0) {
        return res.status(400).json({
          success: false,
          message: 'A valid question string is required',
          error: 'INVALID_QUESTION',
        });
      }

      const data = await this.aiService.getCoachResponse(businessId, question, history);

      return res.status(200).json({
        success: true,
        message: 'AI Coach response generated successfully',
        data,
      });
    } catch (err) {
      return next(err);
    }
  }

  /**
   * Handle Today's Business AI Executive Briefing request.
   */
  async getDailyBrief(req, res, next) {
    try {
      const businessId = req.businessId;
      if (!businessId) {
        return res.status(400).json({
          success: false,
          message: 'Business ID is required in authenticated session',
          error: 'MISSING_BUSINESS_ID',
        });
      }

      const data = await this.aiService.getDailyBrief(businessId);

      return res.status(200).json({
        success: true,
        message: 'Daily business executive brief generated successfully',
        data,
      });
    } catch (err) {
      return next(err);
    }
  }
}

module.exports = new AiController();
