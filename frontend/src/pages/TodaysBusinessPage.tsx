import React from 'react';
import { IndianRupee, Clock, CheckCircle2 } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { StatsCard } from '@/components/ui/StatsCard';
import { formatCurrency } from '@/lib/utils';
import { mockDailyMetrics } from '@/services/mockData';

export const TodaysBusinessPage: React.FC = () => {
  const hourlyData = [
    { hour: '8:00 AM', amount: 1850, orders: 4 },
    { hour: '9:00 AM', amount: 3200, orders: 7 },
    { hour: '10:00 AM', amount: 6400, orders: 11 },
    { hour: '11:00 AM', amount: 5100, orders: 8 },
    { hour: '12:00 PM', amount: 4200, orders: 6 },
    { hour: '1:00 PM', amount: 7700, orders: 6 },
  ];

  const paymentBreakdown = [
    { method: 'UPI (QR Code)', amount: 16800, percentage: 59, color: 'bg-emerald-500' },
    { method: 'Cash', amount: 8250, percentage: 29, color: 'bg-sky-500' },
    { method: 'Card (POS)', amount: 2380, percentage: 8, color: 'bg-indigo-500' },
    { method: 'Khata / Credit', amount: 1020, percentage: 4, color: 'bg-amber-500' },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Today&apos;s Business Pulse</h1>
            <span className="flex h-2.5 w-2.5 relative">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500"></span>
            </span>
          </div>
          <p className="text-xs sm:text-sm text-slate-500">
            Real-time hourly sales stream, active payment splits, and register totals.
          </p>
        </div>

        <div className="text-right">
          <p className="text-xs text-slate-400">Total Day Revenue</p>
          <p className="text-2xl font-black text-slate-900">{formatCurrency(mockDailyMetrics.totalRevenue)}</p>
        </div>
      </div>

      {/* Metrics Row */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <StatsCard
          title="Average Basket Size"
          value={formatCurrency(mockDailyMetrics.averageOrderValue)}
          change={4.8}
          subtitle="per checkout"
          icon={<IndianRupee className="w-5 h-5" />}
          iconBgColor="bg-emerald-50 text-emerald-600"
        />
        <StatsCard
          title="Completed Transactions"
          value={`${mockDailyMetrics.orderCount} bills`}
          change={8.5}
          subtitle="across 2 registers"
          icon={<CheckCircle2 className="w-5 h-5" />}
          iconBgColor="bg-sky-50 text-sky-600"
        />
        <StatsCard
          title="Peak Operating Hour"
          value="10:00 - 11:00 AM"
          subtitle="₹6,400 recorded"
          icon={<Clock className="w-5 h-5" />}
          iconBgColor="bg-indigo-50 text-indigo-600"
        />
      </div>

      {/* Hourly Velocity Stream */}
      <Card className="p-5 space-y-4">
        <h2 className="text-sm font-bold text-slate-900 uppercase tracking-wider">
          Hourly Sales Velocity
        </h2>
        <div className="space-y-3">
          {hourlyData.map((slot) => (
            <div key={slot.hour} className="flex items-center gap-4 text-xs">
              <span className="w-20 text-slate-500 font-medium">{slot.hour}</span>
              <div className="flex-1 bg-slate-100 rounded-full h-3 overflow-hidden">
                <div
                  className="bg-[#0284C7] h-full rounded-full transition-all duration-500"
                  style={{ width: `${(slot.amount / 8000) * 100}%` }}
                />
              </div>
              <span className="w-24 text-right font-bold text-slate-900">
                {formatCurrency(slot.amount)}
              </span>
              <span className="w-16 text-right text-slate-400">{slot.orders} orders</span>
            </div>
          ))}
        </div>
      </Card>

      {/* Payment Method Split */}
      <Card className="p-5 space-y-4">
        <h2 className="text-sm font-bold text-slate-900 uppercase tracking-wider">
          Payment Method Split
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {paymentBreakdown.map((item) => (
            <div key={item.method} className="p-4 rounded-xl bg-slate-50 border border-slate-200">
              <div className="flex items-center justify-between text-xs font-semibold text-slate-600 mb-1">
                <span>{item.method}</span>
                <span>{item.percentage}%</span>
              </div>
              <p className="text-lg font-bold text-slate-900">{formatCurrency(item.amount)}</p>
              <div className="w-full bg-slate-200 h-1.5 rounded-full mt-2 overflow-hidden">
                <div className={`${item.color} h-full rounded-full`} style={{ width: `${item.percentage}%` }} />
              </div>
            </div>
          ))}
        </div>
      </Card>
    </div>
  );
};
