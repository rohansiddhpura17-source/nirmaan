import React, { useState } from 'react';
import { BarChart3, TrendingUp, Calendar } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { StatsCard } from '@/components/ui/StatsCard';
import { formatCurrency } from '@/lib/utils';

export const AnalyticsPage: React.FC = () => {
  const [timeframe, setTimeframe] = useState<'7d' | '30d' | '90d'>('30d');

  const monthlyData = [
    { label: 'Week 1', amount: 142000, height: '65%' },
    { label: 'Week 2', amount: 168000, height: '78%' },
    { label: 'Week 3', amount: 154000, height: '70%' },
    { label: 'Week 4', amount: 189000, height: '88%' },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Analytics & Reports</h1>
          <p className="text-xs sm:text-sm text-slate-500">
            Deep dive into monthly revenue trends, category contributions, and margins.
          </p>
        </div>

        {/* Timeframe pill selector */}
        <div className="flex items-center gap-1 bg-slate-200/70 p-1 rounded-xl">
          {(['7d', '30d', '90d'] as const).map((t) => (
            <button
              key={t}
              onClick={() => setTimeframe(t)}
              className={`px-3 py-1.5 text-xs font-semibold rounded-lg transition-all ${
                timeframe === t
                  ? 'bg-white text-slate-900 shadow-xs'
                  : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              {t === '7d' ? 'Last 7 Days' : t === '30d' ? 'Last 30 Days' : 'This Quarter'}
            </button>
          ))}
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <StatsCard
          title="Monthly Gross Sales"
          value={formatCurrency(653000)}
          change={14.2}
          subtitle="vs previous month"
          icon={<TrendingUp className="w-5 h-5" />}
          iconBgColor="bg-emerald-50 text-emerald-600"
        />
        <StatsCard
          title="Average Profit Margin"
          value="19.4%"
          change={1.8}
          subtitle="store wide"
          icon={<BarChart3 className="w-5 h-5" />}
          iconBgColor="bg-sky-50 text-sky-600"
        />
        <StatsCard
          title="Customer Retention Rate"
          value="74.5%"
          change={3.1}
          subtitle="repeat visits within 30d"
          icon={<Calendar className="w-5 h-5" />}
          iconBgColor="bg-indigo-50 text-indigo-600"
        />
      </div>

      {/* Visual Chart Card */}
      <Card className="p-6 space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-base font-bold text-slate-900">Revenue Progression</h2>
            <p className="text-xs text-slate-500">Weekly performance across the selected period</p>
          </div>
          <span className="text-sm font-bold text-slate-900">{formatCurrency(653000)} Total</span>
        </div>

        {/* Bar chart representation */}
        <div className="h-64 flex items-end justify-between gap-4 pt-8 px-4 border-b border-slate-200">
          {monthlyData.map((bar) => (
            <div key={bar.label} className="flex-1 flex flex-col items-center h-full justify-end group">
              <span className="text-[11px] font-bold text-slate-700 opacity-0 group-hover:opacity-100 transition-opacity mb-1">
                {formatCurrency(bar.amount)}
              </span>
              <div
                className="w-full max-w-[72px] bg-gradient-to-t from-[#0284C7] to-sky-400 rounded-t-xl transition-all duration-300 group-hover:from-indigo-600 group-hover:to-sky-500"
                style={{ height: bar.height }}
              />
              <span className="text-xs font-semibold text-slate-500 mt-2">{bar.label}</span>
            </div>
          ))}
        </div>
      </Card>

      {/* Category Breakdown */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card className="p-5 space-y-4">
          <h2 className="text-sm font-bold text-slate-900 uppercase tracking-wider">
            Category Contribution
          </h2>
          <div className="space-y-3">
            {[
              { cat: 'Groceries & Staples', pct: 64, amt: 417920, color: 'bg-emerald-500' },
              { cat: 'FMCG & Household', pct: 24, amt: 156720, color: 'bg-sky-500' },
              { cat: 'Personal Care', pct: 12, amt: 78360, color: 'bg-indigo-500' },
            ].map((c) => (
              <div key={c.cat} className="space-y-1">
                <div className="flex justify-between text-xs font-medium">
                  <span className="text-slate-700">{c.cat}</span>
                  <span className="font-bold text-slate-900">{formatCurrency(c.amt)} ({c.pct}%)</span>
                </div>
                <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                  <div className={`${c.color} h-full rounded-full`} style={{ width: `${c.pct}%` }} />
                </div>
              </div>
            ))}
          </div>
        </Card>

        <Card className="p-5 space-y-4">
          <h2 className="text-sm font-bold text-slate-900 uppercase tracking-wider">
            Top Performing SKUs
          </h2>
          <div className="divide-y divide-slate-100">
            {[
              { name: 'India Gate Basmati Rice 5kg', sales: 142, revenue: 72420 },
              { name: 'Aashirvaad Atta 10kg', sales: 110, revenue: 54450 },
              { name: 'Fortune Sunflower Oil 1L', sales: 98, revenue: 14210 },
              { name: 'Tata Salt 1kg', sales: 340, revenue: 9520 },
            ].map((sku, idx) => (
              <div key={sku.name} className="py-2.5 flex items-center justify-between text-xs">
                <div className="flex items-center gap-2.5">
                  <span className="w-5 h-5 rounded-full bg-slate-100 font-bold text-slate-600 flex items-center justify-center text-[10px]">
                    {idx + 1}
                  </span>
                  <span className="font-medium text-slate-800">{sku.name}</span>
                </div>
                <div className="text-right">
                  <span className="font-bold text-slate-900">{formatCurrency(sku.revenue)}</span>
                  <span className="text-slate-400 block text-[10px]">{sku.sales} sold</span>
                </div>
              </div>
            ))}
          </div>
        </Card>
      </div>
    </div>
  );
};
