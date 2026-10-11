import { useEffect, useState } from 'react';
import { api } from '../store/useAuthStore';
import { Loader2, Save } from 'lucide-react';

export default function GlobalSettings() {
  const [settings, setSettings] = useState({
    maintenance_mode: false,
    min_app_version: '1.0.0',
    daily_limit_minutes: 30,
  });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    fetchSettings();
  }, []);

  const fetchSettings = async () => {
    try {
      const { data } = await api.get('/settings');
      setSettings(data.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      await api.patch('/settings', settings);
      alert('Global settings updated successfully');
    } catch (err) {
      alert('Failed to update settings');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return <div className="flex justify-center p-8"><Loader2 className="w-8 h-8 animate-spin text-primary-500" /></div>;
  }

  return (
    <div>
      <h1 className="text-2xl font-semibold text-gray-900 mb-6">Global App Settings</h1>
      
      <div className="bg-white shadow sm:rounded-lg mb-6">
        <div className="px-4 py-5 sm:p-6">
          <form className="space-y-6" onSubmit={handleSave}>
            <div>
              <label className="flex items-center space-x-3">
                <input
                  type="checkbox"
                  checked={settings.maintenance_mode === true}
                  onChange={(e) => setSettings({ ...settings, maintenance_mode: e.target.checked })}
                  className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                />
                <span className="text-sm font-medium text-gray-900">Enable Maintenance Mode</span>
              </label>
              <p className="text-sm text-gray-500 ml-7">Turn this on to block app access during server upgrades.</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">Minimum App Version</label>
              <input
                type="text"
                value={settings.min_app_version || ''}
                onChange={(e) => setSettings({ ...settings, min_app_version: e.target.value })}
                className="mt-1 shadow-sm focus:ring-primary-500 focus:border-primary-500 block w-full sm:max-w-xs sm:text-sm border-gray-300 rounded-md p-2 border"
              />
              <p className="mt-2 text-sm text-gray-500">Force users to update if their app version is lower than this.</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">Daily AI Usage Limit (Minutes)</label>
              <input
                type="number"
                value={settings.daily_limit_minutes || 0}
                onChange={(e) => setSettings({ ...settings, daily_limit_minutes: parseInt(e.target.value, 10) })}
                className="mt-1 shadow-sm focus:ring-primary-500 focus:border-primary-500 block w-full sm:max-w-xs sm:text-sm border-gray-300 rounded-md p-2 border"
              />
              <p className="mt-2 text-sm text-gray-500">Maximum minutes of Gemini Live audio per device per day.</p>
            </div>

            <div>
              <button
                type="submit"
                disabled={saving}
                className="inline-flex items-center justify-center px-4 py-2 border border-transparent shadow-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 focus:outline-none disabled:opacity-50"
              >
                {saving ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : <Save className="w-4 h-4 mr-2" />}
                Save Changes
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
