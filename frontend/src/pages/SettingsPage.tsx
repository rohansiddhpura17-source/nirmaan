import React, { useState } from 'react';
import { Save, Receipt, Bell, Sliders } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { Button } from '@/components/ui/Button';

export const SettingsPage: React.FC = () => {
  const [settings, setSettings] = useState({
    storeName: 'Kirana King Superstore',
    receiptFooter: 'Thank you for shopping with us! Visit again.',
    enableGst: true,
    defaultGstRate: '5',
    autoPrintReceipt: true,
    soundOnScan: true,
    roundToRupee: true,
    lowStockNotifications: true,
  });

  const [saved, setSaved] = useState(false);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  return (
    <form onSubmit={handleSave} className="space-y-6 max-w-3xl mx-auto">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Store Settings</h1>
          <p className="text-xs sm:text-sm text-slate-500">
            Configure POS billing parameters, tax rates, and alert options.
          </p>
        </div>

        <Button type="submit" variant="primary" leftIcon={<Save className="w-4 h-4" />}>
          {saved ? 'Settings Saved!' : 'Save Changes'}
        </Button>
      </div>

      {/* POS Configuration */}
      <Card className="space-y-4">
        <div className="flex items-center gap-2 text-slate-900 font-bold text-sm">
          <Receipt className="w-4 h-4 text-sky-600" />
          <span>POS & Billing Behavior</span>
        </div>

        <Input
          label="Store Display Name on Invoices"
          value={settings.storeName}
          onChange={(e) => setSettings({ ...settings, storeName: e.target.value })}
        />

        <Input
          label="Receipt Footer Note"
          value={settings.receiptFooter}
          onChange={(e) => setSettings({ ...settings, receiptFooter: e.target.value })}
        />

        <div className="space-y-3 pt-2">
          <label className="flex items-center justify-between p-3 rounded-xl bg-slate-50 border border-slate-200 cursor-pointer">
            <div>
              <p className="text-xs font-semibold text-slate-800">Auto-Print Thermal Receipt</p>
              <p className="text-[11px] text-slate-500">Trigger printer immediately when payment is confirmed</p>
            </div>
            <input
              type="checkbox"
              checked={settings.autoPrintReceipt}
              onChange={(e) => setSettings({ ...settings, autoPrintReceipt: e.target.checked })}
              className="w-4 h-4 rounded text-sky-600 focus:ring-sky-500"
            />
          </label>

          <label className="flex items-center justify-between p-3 rounded-xl bg-slate-50 border border-slate-200 cursor-pointer">
            <div>
              <p className="text-xs font-semibold text-slate-800">Audio Chime on Barcode Scan</p>
              <p className="text-[11px] text-slate-500">Play confirmation tone on handheld barcode read</p>
            </div>
            <input
              type="checkbox"
              checked={settings.soundOnScan}
              onChange={(e) => setSettings({ ...settings, soundOnScan: e.target.checked })}
              className="w-4 h-4 rounded text-sky-600 focus:ring-sky-500"
            />
          </label>

          <label className="flex items-center justify-between p-3 rounded-xl bg-slate-50 border border-slate-200 cursor-pointer">
            <div>
              <p className="text-xs font-semibold text-slate-800">Auto Round-off to Nearest Rupee</p>
              <p className="text-[11px] text-slate-500">Simplify cash transactions at the checkout counter</p>
            </div>
            <input
              type="checkbox"
              checked={settings.roundToRupee}
              onChange={(e) => setSettings({ ...settings, roundToRupee: e.target.checked })}
              className="w-4 h-4 rounded text-sky-600 focus:ring-sky-500"
            />
          </label>
        </div>
      </Card>

      {/* Taxes & GST */}
      <Card className="space-y-4">
        <div className="flex items-center gap-2 text-slate-900 font-bold text-sm">
          <Sliders className="w-4 h-4 text-emerald-600" />
          <span>GST & Taxation</span>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div className="space-y-1.5">
            <label htmlFor="default-gst-rate" className="block text-sm font-medium text-slate-700">Default GST Slab</label>
            <select
              id="default-gst-rate"
              value={settings.defaultGstRate}
              onChange={(e) => setSettings({ ...settings, defaultGstRate: e.target.value })}
              className="block w-full h-11 rounded-xl border border-slate-300 bg-white px-3.5 text-sm text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#0284C7] focus:border-[#0284C7]"
            >
              <option value="0">0% (Nil / Exempted Foodgrains)</option>
              <option value="5">5% (Packaged Essentials)</option>
              <option value="12">12% (Standard FMCG)</option>
              <option value="18">18% (Personal Care & Confectionery)</option>
            </select>
          </div>
        </div>
      </Card>

      {/* Notifications */}
      <Card className="space-y-4">
        <div className="flex items-center gap-2 text-slate-900 font-bold text-sm">
          <Bell className="w-4 h-4 text-indigo-600" />
          <span>Alerts & Notifications</span>
        </div>

        <label className="flex items-center justify-between p-3 rounded-xl bg-slate-50 border border-slate-200 cursor-pointer">
          <div>
            <p className="text-xs font-semibold text-slate-800">Critical Low Stock Push Notifications</p>
            <p className="text-[11px] text-slate-500">Alert store managers when items reach min threshold</p>
          </div>
          <input
            type="checkbox"
            checked={settings.lowStockNotifications}
            onChange={(e) => setSettings({ ...settings, lowStockNotifications: e.target.checked })}
            className="w-4 h-4 rounded text-sky-600 focus:ring-sky-500"
          />
        </label>
      </Card>
    </form>
  );
};
