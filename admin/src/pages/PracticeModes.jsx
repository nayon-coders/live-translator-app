import { useEffect, useState } from 'react';
import { api } from '../store/useAuthStore';
import { Loader2 } from 'lucide-react';

export default function PracticeModes() {
  const [modes, setModes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [editingId, setEditingId] = useState(null);
  const [formData, setFormData] = useState({});

  useEffect(() => {
    fetchModes();
  }, []);

  const fetchModes = async () => {
    try {
      const { data } = await api.get('/practice-modes');
      setModes(data.data || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleEdit = (mode) => {
    setEditingId(mode.key);
    setFormData(mode);
  };

  const handleSave = async (key) => {
    try {
      await api.patch(`/practice-modes/${key}`, {
        title: formData.title,
        prompt: formData.prompt,
        opening_line: formData.opening_line,
        is_enabled: formData.is_enabled,
      });
      setModes(modes.map(m => m.key === key ? { ...m, ...formData } : m));
      setEditingId(null);
    } catch (err) {
      alert('Failed to update mode');
    }
  };

  if (loading) {
    return <div className="flex justify-center p-8"><Loader2 className="w-8 h-8 animate-spin text-primary-500" /></div>;
  }

  return (
    <div>
      <h1 className="text-2xl font-semibold text-gray-900 mb-6">AI English Teacher - Practice Modes</h1>
      <p className="text-gray-500 mb-6">Control the behavior and prompts for each conversation scenario.</p>
      
      <div className="space-y-6">
        {modes.length === 0 ? (
          <div className="bg-white shadow sm:rounded-lg p-10 text-center text-gray-500">
            No practice modes configured in database yet.
          </div>
        ) : (
          modes.map((mode) => (
            <div key={mode.key} className="bg-white shadow sm:rounded-lg p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-medium text-gray-900">{mode.title}</h3>
                {editingId !== mode.key && (
                  <button
                    onClick={() => handleEdit(mode)}
                    className="text-sm font-medium text-primary-600 hover:text-primary-500"
                  >
                    Edit Configuration
                  </button>
                )}
              </div>
              
              {editingId === mode.key ? (
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Display Title</label>
                    <input
                      type="text"
                      value={formData.title}
                      onChange={e => setFormData({...formData, title: e.target.value})}
                      className="mt-1 block w-full sm:text-sm border-gray-300 rounded-md p-2 border"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">System Prompt (AI Instructions)</label>
                    <textarea
                      rows={4}
                      value={formData.prompt || ''}
                      onChange={e => setFormData({...formData, prompt: e.target.value})}
                      className="mt-1 block w-full sm:text-sm border-gray-300 rounded-md p-2 border"
                      placeholder="e.g. You are a waiter in a restaurant. Speak English."
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">Opening Line (AI says this first)</label>
                    <input
                      type="text"
                      value={formData.opening_line || ''}
                      onChange={e => setFormData({...formData, opening_line: e.target.value})}
                      className="mt-1 block w-full sm:text-sm border-gray-300 rounded-md p-2 border"
                    />
                  </div>
                  <div className="flex items-center">
                    <input
                      type="checkbox"
                      checked={formData.is_enabled}
                      onChange={e => setFormData({...formData, is_enabled: e.target.checked})}
                      className="h-4 w-4 text-primary-600 border-gray-300 rounded"
                    />
                    <span className="ml-2 text-sm text-gray-700">Enable this mode</span>
                  </div>
                  
                  <div className="flex justify-end space-x-3 mt-4">
                    <button onClick={() => setEditingId(null)} className="px-4 py-2 border rounded-md text-sm text-gray-700 hover:bg-gray-50">Cancel</button>
                    <button onClick={() => handleSave(mode.key)} className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700">Save Changes</button>
                  </div>
                </div>
              ) : (
                <div className="text-sm text-gray-500 space-y-2">
                  <p><span className="font-medium text-gray-700">Status:</span> {mode.is_enabled ? 'Enabled' : 'Disabled'}</p>
                  <p><span className="font-medium text-gray-700">Opening Line:</span> {mode.opening_line}</p>
                  <p className="line-clamp-2"><span className="font-medium text-gray-700">Prompt:</span> {mode.prompt}</p>
                </div>
              )}
            </div>
          ))
        )}
      </div>
    </div>
  );
}
