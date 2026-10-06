import React from 'react';
import { CheckCircle2, Sparkles, TrendingUp } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { mockBusinessHealth } from '@/services/mockData';
import { useNavigate } from 'react-router-dom';

export const BusinessHealthPage: React.FC = () => {
  const navigate = useNavigate();
  const { overallScore, profitabilityScore, inventoryEfficiencyScore, customerRetentionScore, cashFlowScore, insights, recommendations } =
    mockBusinessHealth;

  const pillars = [
    { title: 'Profitability Margin', score: profitabilityScore, desc: 'Gross margin vs wholesale cost' },
    { title: 'Inventory Efficiency', score: inventoryEfficiencyScore, desc: 'Turnover rate and low dead-stock' },
    { title: 'Customer Retention', score: customerRetentionScore, desc: 'Loyal repeat visitors & order frequency' },
    { title: 'Cash Flow & Khata Health', score: cashFlowScore, desc: 'Credit settlement & cash conversion cycle' },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Business Health Score</h1>
          <p className="text-xs sm:text-sm text-slate-500">
            Holistic AI operational health evaluation based on sales velocity and working capital.
          </p>
        </div>

        <Button
          variant="ai"
          onClick={() => navigate('/ai-coach')}
          leftIcon={<Sparkles className="w-4 h-4" />}
        >
          Consult AI Coach
        </Button>
      </div>

      {/* Main Score Hero Card */}
      <Card variant="navy" className="p-6 md:p-8">
        <div className="flex flex-col md:flex-row items-center justify-between gap-6">
          <div className="space-y-2 text-center md:text-left">
            <Badge variant="success" size="md" className="bg-emerald-500/20 text-emerald-300 border-emerald-400/30">
              Optimal Health Status
            </Badge>
            <h2 className="text-2xl md:text-3xl font-extrabold text-white tracking-tight">
              Your Business Health is 84 / 100
            </h2>
            <p className="text-xs md:text-sm text-slate-300 max-w-lg leading-relaxed">
              Kirana King Superstore outperforms 82% of similar regional grocery businesses in profit
              discipline and repeat customer loyalty.
            </p>
          </div>

          <div className="flex flex-col items-center justify-center w-36 h-36 rounded-full bg-slate-800/80 border-4 border-sky-400 text-white shadow-xl shrink-0">
            <span className="text-4xl font-black">{overallScore}</span>
            <span className="text-[11px] font-semibold text-sky-300 uppercase tracking-widest">
              Score
            </span>
          </div>
        </div>
      </Card>

      {/* 4 Pillars Breakdown */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {pillars.map((pillar) => (
          <Card key={pillar.title} className="p-4 space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold text-slate-700">{pillar.title}</span>
              <span className="text-sm font-bold text-sky-600">{pillar.score}/100</span>
            </div>
            <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
              <div
                className="bg-[#0284C7] h-full rounded-full transition-all duration-500"
                style={{ width: `${pillar.score}%` }}
              />
            </div>
            <p className="text-[11px] text-slate-400 leading-snug">{pillar.desc}</p>
          </Card>
        ))}
      </div>

      {/* AI Key Insights and Actionable Recommendations */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Insights */}
        <Card className="p-5 space-y-4">
          <div className="flex items-center gap-2 text-indigo-600">
            <Sparkles className="w-4 h-4" />
            <h3 className="text-sm font-bold uppercase tracking-wider text-slate-900">
              Key Diagnostic Findings
            </h3>
          </div>
          <ul className="space-y-3">
            {insights.map((insight, idx) => (
              <li key={idx} className="flex items-start gap-3 text-xs text-slate-600">
                <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0 mt-0.5" />
                <span>{insight}</span>
              </li>
            ))}
          </ul>
        </Card>

        {/* Recommendations */}
        <Card className="p-5 space-y-4">
          <div className="flex items-center gap-2 text-sky-600">
            <TrendingUp className="w-4 h-4" />
            <h3 className="text-sm font-bold uppercase tracking-wider text-slate-900">
              Recommended Next Steps
            </h3>
          </div>
          <ul className="space-y-3">
            {recommendations.map((rec, idx) => (
              <li key={idx} className="flex items-start gap-3 text-xs text-slate-600">
                <span className="w-5 h-5 rounded-full bg-sky-100 text-sky-700 font-bold text-[10px] flex items-center justify-center shrink-0">
                  {idx + 1}
                </span>
                <span>{rec}</span>
              </li>
            ))}
          </ul>
        </Card>
      </div>
    </div>
  );
};
