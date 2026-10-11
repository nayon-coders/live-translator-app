import { useEffect, useState } from 'react';
import { api } from '../store/useAuthStore';
import { Users, Activity, Clock, PhoneCall, ArrowUpRight, Smartphone } from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

export default function Dashboard() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const { data } = await api.get('/stats');
        setStats(data);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetchStats();
  }, []);

  if (loading) {
    return (
      <div className="flex h-full items-center justify-center">
        <div className="flex flex-col items-center">
          <div className="w-12 h-12 border-4 border-primary-200 border-t-primary-600 rounded-full animate-spin"></div>
          <p className="mt-4 text-gray-500 font-medium tracking-wide">Loading Insights...</p>
        </div>
      </div>
    );
  }

  const metrics = [
    { name: 'App Downloads (Devices)', stat: stats?.metrics?.total_devices || 0, icon: Smartphone, color: 'from-blue-500 to-cyan-400', shadow: 'shadow-blue-500/30' },
    { name: 'Total Live Sessions', stat: stats?.metrics?.total_sessions || 0, icon: Activity, color: 'from-primary-500 to-indigo-500', shadow: 'shadow-indigo-500/30' },
    { name: 'Sessions Today', stat: stats?.metrics?.today_sessions || 0, icon: PhoneCall, color: 'from-pink-500 to-rose-400', shadow: 'shadow-rose-500/30' },
    { name: 'Usage Today (min)', stat: stats?.metrics?.today_duration_minutes || 0, icon: Clock, color: 'from-amber-500 to-orange-400', shadow: 'shadow-orange-500/30' },
  ];

  // Dummy data for the chart since backend doesn't provide historical data yet
  const chartData = [
    { name: 'Mon', sessions: 12 },
    { name: 'Tue', sessions: 19 },
    { name: 'Wed', sessions: 15 },
    { name: 'Thu', sessions: 22 },
    { name: 'Fri', sessions: 30 },
    { name: 'Sat', sessions: 45 },
    { name: 'Sun', sessions: stats?.metrics?.today_sessions || 50 },
  ];

  return (
    <div className="max-w-7xl mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 tracking-tight">Welcome back, Admin</h1>
          <p className="text-gray-500 mt-1">Here is what's happening with Translivo today.</p>
        </div>
      </div>
      
      {/* Metrics Grid */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {metrics.map((item) => (
          <div key={item.name} className={`relative overflow-hidden bg-white rounded-2xl p-6 shadow-xl ${item.shadow} border border-gray-100 transition-transform hover:-translate-y-1 duration-300`}>
            <div className={`absolute top-0 right-0 -mr-8 -mt-8 w-32 h-32 rounded-full bg-gradient-to-br ${item.color} opacity-10 blur-2xl`}></div>
            <div className="flex items-center justify-between">
              <div className={`flex items-center justify-center w-12 h-12 rounded-xl bg-gradient-to-br ${item.color} shadow-lg text-white`}>
                <item.icon className="h-6 w-6" aria-hidden="true" />
              </div>
              <span className="flex items-center text-sm font-medium text-emerald-500 bg-emerald-50 px-2 py-1 rounded-full">
                <ArrowUpRight className="w-4 h-4 mr-1" />
                12%
              </span>
            </div>
            <div className="mt-6">
              <h3 className="text-sm font-medium text-gray-500">{item.name}</h3>
              <p className="text-4xl font-extrabold text-gray-900 mt-1 tracking-tight">{item.stat}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Chart Section */}
        <div className="lg:col-span-2 bg-white rounded-2xl shadow-lg border border-gray-100 p-6">
          <h2 className="text-lg font-bold text-gray-900 mb-6">Activity Overview (This Week)</h2>
          <div className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={chartData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="colorSessions" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#6366f1" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#6366f1" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e5e7eb" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#6b7280', fontSize: 12}} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{fill: '#6b7280', fontSize: 12}} />
                <Tooltip 
                  contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }}
                  cursor={{stroke: '#cbd5e1', strokeWidth: 1, strokeDasharray: '4 4'}}
                />
                <Area type="monotone" dataKey="sessions" stroke="#6366f1" strokeWidth={3} fillOpacity={1} fill="url(#colorSessions)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Recent Activity List */}
        <div className="bg-white rounded-2xl shadow-lg border border-gray-100 p-6">
          <h2 className="text-lg font-bold text-gray-900 mb-6">Recent Sessions</h2>
          <div className="flow-root">
            <ul role="list" className="-mb-8">
              {stats?.recent_sessions?.map((session, sessionIdx) => (
                <li key={session.id}>
                  <div className="relative pb-8">
                    {sessionIdx !== (stats?.recent_sessions?.length || 0) - 1 ? (
                      <span className="absolute top-4 left-4 -ml-px h-full w-0.5 bg-gray-200" aria-hidden="true" />
                    ) : null}
                    <div className="relative flex space-x-3">
                      <div>
                        <span className={`h-8 w-8 rounded-full flex items-center justify-center ring-8 ring-white ${session.status === 'completed' ? 'bg-emerald-500' : 'bg-amber-500'}`}>
                          <Activity className="h-4 w-4 text-white" aria-hidden="true" />
                        </span>
                      </div>
                      <div className="flex min-w-0 flex-1 justify-between space-x-4 pt-1.5">
                        <div>
                          <p className="text-sm text-gray-500">
                            Device <span className="font-medium text-gray-900">{session.device_id}</span>
                            {' '}started a session
                          </p>
                          <p className="text-xs text-gray-400 mt-0.5">Status: {session.status}</p>
                        </div>
                        <div className="whitespace-nowrap text-right text-sm text-gray-500">
                          <time dateTime={session.started_at}>
                            {new Date(session.started_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}
                          </time>
                        </div>
                      </div>
                    </div>
                  </div>
                </li>
              ))}
              {(!stats?.recent_sessions || stats?.recent_sessions?.length === 0) && (
                <div className="text-center py-6 text-gray-500 text-sm">
                  No active usage yet.
                </div>
              )}
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
