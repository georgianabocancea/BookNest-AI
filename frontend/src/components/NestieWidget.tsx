import React, { useState, useRef, useEffect } from 'react';
import API from '../services/api';

interface Message {
  role: 'user' | 'assistant';
  content: string;
}

const NestieWidget = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [messages, setMessages] = useState<Message[]>([
    {
      role: 'assistant',
      content: "Hi! I'm Nestie 🪺 Your reading assistant. Ask me anything about books, authors, or let me recommend something based on your library!"
    }
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [width, setWidth] = useState(320);
  const [height, setHeight] = useState(460);
  const [isResizing, setIsResizing] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const chatBoxRef = useRef<HTMLDivElement>(null);

  // Load dimensions from localStorage
  useEffect(() => {
    const saved = localStorage.getItem('nestie-dimensions');
    if (saved) {
      const { w, h } = JSON.parse(saved);
      setWidth(w);
      setHeight(h);
    }
  }, []);

  // Save dimensions to localStorage
  useEffect(() => {
    localStorage.setItem('nestie-dimensions', JSON.stringify({ w: width, h: height }));
  }, [width, height]);

  useEffect(() => {
    if (isOpen) {
      messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    }
  }, [messages, isOpen]);

  const handleMouseDown = (e: React.MouseEvent) => {
    e.preventDefault();
    setIsResizing(true);
    const startX = e.clientX;
    const startY = e.clientY;
    const startWidth = width;
    const startHeight = height;

    const handleMouseMove = (moveEvent: MouseEvent) => {
      const deltaX = moveEvent.clientX - startX;
      const deltaY = moveEvent.clientY - startY;
      setWidth(Math.max(300, startWidth - deltaX));
      setHeight(Math.max(300, startHeight - deltaY));
    };

    const handleMouseUp = () => {
      setIsResizing(false);
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('mouseup', handleMouseUp);
    };

    window.addEventListener('mousemove', handleMouseMove);
    window.addEventListener('mouseup', handleMouseUp);
  };

  const sendMessage = async () => {
    if (!input.trim() || loading) return;

    const userMessage: Message = { role: 'user', content: input };
    const updatedMessages = [...messages, userMessage];
    setMessages(updatedMessages);
    setInput('');
    setLoading(true);

    try {
      const res = await API.post('/nestie/chat', {
        messages: updatedMessages
      });
      setMessages(prev => [...prev, {
        role: 'assistant',
        content: res.data.message
      }]);
    } catch (err) {
      setMessages(prev => [...prev, {
        role: 'assistant',
        content: "Sorry, I'm having trouble connecting. Please try again!"
      }]);
    } finally {
      setLoading(false);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  return (
    <div className="fixed bottom-6 right-6 z-50">
      {/* Chat window */}
      {isOpen && (
        <div 
          ref={chatBoxRef}
          className="mb-4 bg-white rounded-2xl shadow-xl flex flex-col overflow-hidden border border-gray-100 relative"
          style={{ width: `${width}px`, height: `${height}px` }}>
          
          {/* Header */}
          <div className="bg-amber-700 px-4 py-3 flex items-center justify-between flex-shrink-0">
            <div className="flex items-center gap-2">
              <span className="text-xl">🪺</span>
              <div>
                <p className="text-white font-semibold text-sm">Nestie</p>
                <p className="text-amber-200 text-xs">Your reading assistant</p>
              </div>
            </div>
            <button
              onClick={() => setIsOpen(false)}
              className="text-amber-200 hover:text-white transition-colors"
            >
              ✕
            </button>
          </div>

          {/* Messages */}
          <div className="flex-1 overflow-y-auto p-4 space-y-3">
            {messages.map((msg, i) => (
              <div key={i} className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}>
                {msg.role === 'assistant' && (
                  <span className="text-lg mr-2 mt-1">🪺</span>
                )}
                <div className={`max-w-xs px-3 py-2 rounded-2xl text-sm leading-relaxed ${
                  msg.role === 'user'
                    ? 'bg-amber-700 text-white rounded-tr-sm'
                    : 'bg-gray-100 text-gray-800 rounded-tl-sm'
                }`}>
                  {msg.content}
                </div>
              </div>
            ))}
            {loading && (
              <div className="flex justify-start">
                <span className="text-lg mr-2">🪺</span>
                <div className="bg-gray-100 px-3 py-2 rounded-2xl rounded-tl-sm">
                  <div className="flex gap-1">
                    <span className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0ms' }} />
                    <span className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '150ms' }} />
                    <span className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '300ms' }} />
                  </div>
                </div>
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>

          {/* Input */}
          <div className="p-3 border-t border-gray-100 flex-shrink-0">
            <div className="flex gap-2">
              <input
                type="text"
                value={input}
                onChange={e => setInput(e.target.value)}
                onKeyDown={handleKeyDown}
                placeholder="Ask Nestie anything..."
                className="flex-1 border border-gray-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-amber-300"
                disabled={loading}
              />
              <button
                onClick={sendMessage}
                disabled={loading || !input.trim()}
                className="bg-amber-700 hover:bg-amber-800 disabled:opacity-50 text-white px-3 py-2 rounded-xl text-sm transition-colors"
              >
                ➤
              </button>
            </div>
          </div>

          {/* Resize handle */}
          <div
            onMouseDown={handleMouseDown}
            className={`absolute top-0 left-0 w-5 h-5 cursor-nw-resize ${isResizing ? 'bg-amber-500' : 'bg-gray-300 hover:bg-amber-400'} transition-colors rounded-br-lg`}
            title="Drag to resize"
          />
        </div>
      )}

      {/* Toggle button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="w-14 h-14 bg-amber-700 hover:bg-amber-800 text-white rounded-full shadow-lg flex items-center justify-center text-2xl transition-all hover:scale-110"
      >
        {isOpen ? '✕' : '🪺'}
      </button>
    </div>
  );
};

export default NestieWidget;