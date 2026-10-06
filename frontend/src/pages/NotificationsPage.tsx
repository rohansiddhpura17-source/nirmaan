import React, { useState } from 'react';
import { Bell, AlertTriangle, CheckCircle2, ShoppingCart, Sparkles } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';

interface NotificationItem {
  id: string;
  title: string;
  message: string;
  type: 'stock' | 'order' | 'ai' | 'credit';
  timestamp: string;
  isRead: boolean;
}

export const NotificationsPage: React.FC = () => {
  const [notifications, setNotifications] = useState<NotificationItem[]>([
    {
      id: 'notif_1',
      title: 'Critical Low Stock: Aashirvaad Atta 10kg',
      message: 'Only 4 bags remaining. You are predicted to run out within 36 hours.',
      type: 'stock',
      timestamp: '15 mins ago',
      isRead: false,
    },
    {
      id: 'notif_2',
      title: 'High-Value Order Received: ORD-2026-0041',
      message: 'Order worth ₹1,060 completed by Amit Patel via Cash.',
      type: 'order',
      timestamp: '1 hour ago',
      isRead: false,
    },
    {
      id: 'notif_3',
      title: 'Weekly AI Growth Audit Ready',
      message: 'Your Business Health Score rose to 84/100 this week. Tap to view diagnostic notes.',
      type: 'ai',
      timestamp: '4 hours ago',
      isRead: true,
    },
    {
      id: 'notif_4',
      title: 'Customer Khata Reminder: Ramesh Gupta',
      message: 'Outstanding credit of ₹1,850 pending for over 14 days.',
      type: 'credit',
      timestamp: 'Yesterday',
      isRead: true,
    },
  ]);

  const markAllAsRead = () => {
    setNotifications((prev) => prev.map((n) => ({ ...n, isRead: true })));
  };

  const clearAll = () => {
    setNotifications([]);
  };

  const getIcon = (type: NotificationItem['type']) => {
    switch (type) {
      case 'stock':
        return <AlertTriangle className="w-4 h-4 text-amber-600" />;
      case 'order':
        return <ShoppingCart className="w-4 h-4 text-sky-600" />;
      case 'ai':
        return <Sparkles className="w-4 h-4 text-indigo-600" />;
      case 'credit':
        return <CheckCircle2 className="w-4 h-4 text-rose-600" />;
    }
  };

  return (
    <div className="space-y-6 max-w-3xl mx-auto">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Notification Center</h1>
          <p className="text-xs sm:text-sm text-slate-500">
            Real-time operational alerts, stock depletion warnings, and AI insights.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm" onClick={markAllAsRead}>
            Mark All as Read
          </Button>
          <Button variant="ghost" size="sm" onClick={clearAll} className="text-rose-600 hover:text-rose-700">
            Clear
          </Button>
        </div>
      </div>

      {/* Notifications List */}
      <div className="space-y-3">
        {notifications.length === 0 ? (
          <Card className="text-center py-12 text-slate-500">
            <Bell className="w-10 h-10 text-slate-300 mx-auto mb-2" />
            <p className="text-sm font-semibold">No notifications</p>
            <p className="text-xs text-slate-400 mt-1">You are all caught up!</p>
          </Card>
        ) : (
          notifications.map((item) => (
            <Card
              key={item.id}
              className={`p-4 transition-all hover:shadow-md ${
                !item.isRead ? 'bg-sky-50/30 border-l-4 border-l-sky-500' : ''
              }`}
            >
              <div className="flex items-start gap-3.5">
                <div className="p-2 rounded-xl bg-slate-100 shrink-0 mt-0.5">
                  {getIcon(item.type)}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between gap-2">
                    <h3 className="text-xs md:text-sm font-bold text-slate-900 truncate">
                      {item.title}
                    </h3>
                    <span className="text-[11px] text-slate-400 shrink-0">{item.timestamp}</span>
                  </div>
                  <p className="text-xs text-slate-600 mt-1 leading-relaxed">{item.message}</p>
                </div>
              </div>
            </Card>
          ))
        )}
      </div>
    </div>
  );
};
