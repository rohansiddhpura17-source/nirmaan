import React, { useState } from 'react';
import { Sparkles, Send, Bot, User, Zap } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { useAuth } from '@/context/AuthContext';

interface ChatMessage {
  id: string;
  sender: 'ai' | 'user';
  text: string;
  timestamp: string;
  suggestedActions?: string[];
}

export const AiCoachPage: React.FC = () => {
  const { user } = useAuth();
  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      id: '1',
      sender: 'ai',
      text: `Hello ${user?.displayName || 'Store Owner'}! I am your Nirmaan AI Business Coach. I analyze your store sales, inventory velocities, and khata balances to help you maximize net profits. How can I assist you today?`,
      timestamp: '10:00 AM',
      suggestedActions: [
        'Analyze low stock risk for this weekend',
        'How can I raise grocery profit margins?',
        'Draft a WhatsApp promo message for customers',
      ],
    },
  ]);
  const [input, setInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);

  const handleSend = (textToSend?: string) => {
    const query = textToSend || input;
    if (!query.trim()) return;

    const userMsg: ChatMessage = {
      id: Date.now().toString(),
      sender: 'user',
      text: query,
      timestamp: 'Just now',
    };

    setMessages((prev) => [...prev, userMsg]);
    if (!textToSend) setInput('');
    setIsTyping(true);

    setTimeout(() => {
      let aiResponseText = `Based on your recent 30-day store transactions for ${user?.businessName}:
      
1. **High Margin Potential**: Your Groceries category currently generates 18.2% margin. Bundling India Gate Basmati Rice with Fortune Sunflower Oil as a 'Kitchen Essentials Combo' will bump basket size by ~₹320 with an immediate 2.4% net margin gain.
2. **Stock Alert**: Restock Aashirvaad Atta 10kg (only 4 bags left) before Friday afternoon to prevent ₹3,800 in lost weekend revenue.
3. **Credit Followup**: Send automated friendly WhatsApp reminders to the 2 customers with pending balances over ₹400.`;

      if (query.toLowerCase().includes('promo') || query.toLowerCase().includes('whatsapp')) {
        aiResponseText = `Here is a high-converting WhatsApp message tailored for your Kirana customers:

"🌟 *Special Weekend Offer from ${user?.businessName}!* 🌟
Stock up your kitchen with fresh staples at unbeatable prices!
🍚 India Gate Basmati Rice (5kg) + 🌻 Fortune Sunflower Oil (1L) Combo at just *₹640*!
Order on WhatsApp or visit our shop today. Free doorstep delivery on orders above ₹500!
📞 Call/WhatsApp: ${user?.phone || '+91 98765 43210'}"`;
      }

      const aiMsg: ChatMessage = {
        id: (Date.now() + 1).toString(),
        sender: 'ai',
        text: aiResponseText,
        timestamp: 'Just now',
      };
      setMessages((prev) => [...prev, aiMsg]);
      setIsTyping(false);
    }, 600);
  };

  return (
    <div className="space-y-4 max-w-4xl mx-auto h-[calc(100vh-8rem)] flex flex-col">
      {/* Top AI Header */}
      <div className="flex items-center justify-between p-4 rounded-2xl bg-gradient-to-r from-indigo-900 via-slate-900 to-indigo-950 text-white shadow-md">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-indigo-600/80 flex items-center justify-center text-white shadow-sm ring-1 ring-indigo-400/50">
            <Sparkles className="w-5 h-5 text-indigo-200" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-base font-bold text-white tracking-tight">
                Nirmaan AI Business Coach
              </h2>
              <Badge variant="ai" size="sm" className="bg-indigo-500/20 text-indigo-300 border-indigo-400/30">
                Gemini 2.5 Brain
              </Badge>
            </div>
            <p className="text-xs text-indigo-200/80">
              Trained on Indian retail patterns, local supply chains, and inventory forecasting.
            </p>
          </div>
        </div>
      </div>

      {/* Chat Messages Timeline */}
      <Card padded={false} className="flex-1 p-4 md:p-6 overflow-y-auto space-y-4 bg-slate-50/50">
        {messages.map((msg) => (
          <div
            key={msg.id}
            className={`flex items-start gap-3 ${
              msg.sender === 'user' ? 'flex-row-reverse' : ''
            }`}
          >
            <div
              className={`w-8 h-8 rounded-xl flex items-center justify-center shrink-0 ${
                msg.sender === 'user'
                  ? 'bg-sky-600 text-white'
                  : 'bg-indigo-600 text-white shadow-sm'
              }`}
            >
              {msg.sender === 'user' ? (
                <User className="w-4 h-4" />
              ) : (
                <Bot className="w-4 h-4" />
              )}
            </div>

            <div
              className={`max-w-xl rounded-2xl p-4 text-xs md:text-sm whitespace-pre-line leading-relaxed shadow-xs ${
                msg.sender === 'user'
                  ? 'bg-[#0284C7] text-white rounded-tr-none'
                  : 'bg-white text-slate-800 border border-slate-200/80 rounded-tl-none'
              }`}
            >
              {msg.text}

              {msg.suggestedActions && (
                <div className="mt-3 pt-3 border-t border-slate-100 flex flex-wrap gap-1.5">
                  {msg.suggestedActions.map((action) => (
                    <button
                      key={action}
                      onClick={() => handleSend(action)}
                      className="text-xs bg-indigo-50 text-indigo-700 hover:bg-indigo-100 px-2.5 py-1 rounded-lg font-medium transition-colors border border-indigo-100 flex items-center gap-1"
                    >
                      <Zap className="w-3 h-3 text-indigo-500" />
                      {action}
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>
        ))}

        {isTyping && (
          <div className="flex items-center gap-2 text-xs text-indigo-600 font-semibold p-2">
            <Sparkles className="w-4 h-4 animate-spin text-indigo-500" />
            Nirmaan AI is analyzing your store metrics...
          </div>
        )}
      </Card>

      {/* Input bar */}
      <form
        onSubmit={(e) => {
          e.preventDefault();
          handleSend();
        }}
        className="flex items-center gap-2"
      >
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Ask AI Coach: e.g. 'How can I clear slow-moving inventory?'"
          className="flex-1 h-12 px-4 rounded-xl border border-slate-300 bg-white text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 transition-all text-slate-800 placeholder:text-slate-400"
        />
        <Button
          type="submit"
          variant="ai"
          size="lg"
          className="h-12 px-5"
          disabled={!input.trim()}
          rightIcon={<Send className="w-4 h-4" />}
        >
          Send
        </Button>
      </form>
    </div>
  );
};
