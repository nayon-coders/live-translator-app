import { useEffect, useState } from 'react';
import { api } from '../store/useAuthStore';
import { Loader2, Key } from 'lucide-react';

export default function Settings() {
  const [apiKey, setApiKey] = useState('');
  const [keyStatus, setKeyStatus] = useState(null);
  const [isSaving, setIsSaving] = useState(false);
  const [isTesting, setIsTesting] = useState(false);

  useEffect(() => {
    fetchKeyStatus();
  }, []);

  const fetchKeyStatus = async () => {
    try {
      const { data } = await api.get('/secrets/gemini');
      setKeyStatus(data);
    } catch (err) {
      console.error(err);
    }
  };

  const handleSaveKey = async (e) => {
    e.preventDefault();
    if (!apiKey) return;
    
    setIsSaving(true);
    try {
      await api.post('/secrets/gemini', { api_key: apiKey });
      setApiKey('');
      await fetchKeyStatus();
      alert('API Key saved successfully!');
    } catch (err) {
      alert(err.response?.data?.error?.message || 'Failed to save key');
    } finally {
      setIsSaving(false);
    }
  };

  const handleTestKey = async () => {
    setIsTesting(true);
    try {
      const { data } = await api.post('/secrets/gemini/test');
      if (data.success) {
        alert('Success: ' + data.message);
      } else {
        alert('Failed: ' + data.details);
      }
    } catch (err) {
      alert('Test failed entirely');
    } finally {
      setIsTesting(false);
    }
  };

  return (
    <div>
      <h1 className="text-2xl font-semibold text-gray-900 mb-6">Security & AI Settings</h1>
      
      <div className="bg-white shadow sm:rounded-lg mb-6">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg leading-6 font-medium text-gray-900 flex items-center">
            <Key className="w-5 h-5 mr-2 text-gray-400" />
            Gemini API Key
          </h3>
          <div className="mt-2 max-w-xl text-sm text-gray-500">
            <p>
              Your Gemini API Key is encrypted securely in the database. 
              {keyStatus?.exists 
                ? ` A key is currently active (ending in ${keyStatus.last4}).` 
                : ' No key is currently configured.'}
            </p>
          </div>
          
          <form className="mt-5 sm:flex sm:items-center" onSubmit={handleSaveKey}>
            <div className="w-full sm:max-w-xs">
              <input
                type="text"
                value={apiKey}
                onChange={(e) => setApiKey(e.target.value)}
                className="shadow-sm focus:ring-primary-500 focus:border-primary-500 block w-full sm:text-sm border-gray-300 rounded-md p-2 border"
                placeholder={keyStatus?.exists ? "Enter new key to replace..." : "Enter Gemini API Key"}
              />
            </div>
            <button
              type="submit"
              disabled={isSaving || !apiKey}
              className="mt-3 w-full inline-flex items-center justify-center px-4 py-2 border border-transparent shadow-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 focus:outline-none disabled:opacity-50 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
            >
              {isSaving ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Save Key'}
            </button>
            
            {keyStatus?.exists && (
              <button
                type="button"
                onClick={handleTestKey}
                disabled={isTesting}
                className="mt-3 w-full inline-flex items-center justify-center px-4 py-2 border border-gray-300 shadow-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none disabled:opacity-50 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
              >
                {isTesting ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Test Connection'}
              </button>
            )}
          </form>
        </div>
      </div>
    </div>
  );
}
