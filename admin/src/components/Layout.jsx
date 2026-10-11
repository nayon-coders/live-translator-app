import { Outlet, Navigate, NavLink } from 'react-router-dom';
import { useAuthStore } from '../store/useAuthStore';
import { LayoutDashboard, Settings, Languages, MessageSquare, Key, Bot, Settings2, LogOut } from 'lucide-react';

export default function Layout() {
  const { isAuthenticated, admin, logout } = useAuthStore();

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  const navItems = [
    { name: 'Dashboard', icon: LayoutDashboard, path: '/' },
    { name: 'Features', icon: MessageSquare, path: '/features' },
    { name: 'Languages', icon: Languages, path: '/languages' },
    { name: 'Practice Modes', icon: Bot, path: '/practice-modes' },
    { name: 'AI Key', icon: Key, path: '/gemini' },
    { name: 'Global Settings', icon: Settings2, path: '/settings' },
  ];

  return (
    <div className="h-screen flex overflow-hidden bg-gray-50">
      {/* Sidebar */}
      <div className="w-64 bg-dark-900 flex flex-col shadow-2xl z-10">
        <div className="flex items-center justify-center h-20 bg-dark-900 border-b border-dark-800">
          <span className="text-white font-extrabold text-2xl tracking-widest bg-clip-text text-transparent bg-gradient-to-r from-primary-400 to-purple-400">
            TRANSLIVO
          </span>
        </div>
        <div className="flex-1 overflow-y-auto pt-6 pb-4">
          <nav className="mt-2 px-4 space-y-2">
            {navItems.map((item) => (
              <NavLink
                key={item.name}
                to={item.path}
                className={({ isActive }) =>
                  `group flex items-center px-4 py-3 text-sm font-medium rounded-xl transition-all duration-200 ${
                    isActive
                      ? 'bg-gradient-to-r from-primary-600 to-primary-500 text-white shadow-lg shadow-primary-500/30'
                      : 'text-gray-400 hover:bg-dark-800 hover:text-white'
                  }`
                }
              >
                {({ isActive }) => (
                  <>
                    <item.icon
                      className={`mr-4 h-5 w-5 transition-colors ${
                        isActive ? 'text-white' : 'text-gray-500 group-hover:text-gray-300'
                      }`}
                    />
                    {item.name}
                  </>
                )}
              </NavLink>
            ))}
          </nav>
        </div>
        <div className="flex-shrink-0 flex bg-dark-800 p-4">
          <div className="flex items-center w-full">
            <div className="ml-3 flex-1">
              <p className="text-sm font-medium text-white">{admin?.name}</p>
              <p className="text-xs font-medium text-gray-400 group-hover:text-gray-300">
                {admin?.role?.toUpperCase()}
              </p>
            </div>
            <button 
              onClick={logout}
              className="p-2 text-gray-400 hover:text-white"
              title="Logout"
            >
              <LogOut className="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>

      {/* Main content */}
      <div className="flex flex-col w-0 flex-1 overflow-hidden">
        <main className="flex-1 relative z-0 overflow-y-auto focus:outline-none">
          <div className="py-6 px-8">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
}
