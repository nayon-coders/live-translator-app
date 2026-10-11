import { useEffect, useState } from 'react';
import { api } from '../store/useAuthStore';
import { Loader2 } from 'lucide-react';

export default function Languages() {
  const [languages, setLanguages] = useState([]);
  const [loading, setLoading] = useState(true);
  const [savingId, setSavingId] = useState(null);

  useEffect(() => {
    fetchLanguages();
  }, []);

  const fetchLanguages = async () => {
    try {
      const { data } = await api.get('/languages');
      setLanguages(data.data || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const toggleLanguage = async (lang) => {
    setSavingId(lang.code);
    try {
      await api.patch(`/languages/${lang.code}`, { is_enabled: !lang.is_enabled });
      setLanguages(languages.map(l => l.code === lang.code ? { ...l, is_enabled: !lang.is_enabled } : l));
    } catch (err) {
      alert('Failed to update language');
    } finally {
      setSavingId(null);
    }
  };

  if (loading) {
    return <div className="flex justify-center p-8"><Loader2 className="w-8 h-8 animate-spin text-primary-500" /></div>;
  }

  return (
    <div>
      <h1 className="text-2xl font-semibold text-gray-900 mb-6">Supported Languages</h1>
      
      <div className="bg-white shadow overflow-hidden sm:rounded-md">
        <ul role="list" className="divide-y divide-gray-200">
          {languages.map((lang) => (
            <li key={lang.code} className="px-6 py-4 flex items-center justify-between hover:bg-gray-50">
              <div>
                <p className="text-sm font-medium text-gray-900">{lang.name} ({lang.native_name})</p>
                <p className="text-sm text-gray-500">ISO3: {lang.iso3} | Code: {lang.code}</p>
              </div>
              
              <div className="flex items-center">
                <span className="mr-3 text-sm text-gray-500">
                  {lang.is_enabled ? 'Enabled' : 'Disabled'}
                </span>
                
                <button
                  onClick={() => toggleLanguage(lang)}
                  disabled={savingId === lang.code}
                  className={`${
                    lang.is_enabled ? 'bg-primary-600' : 'bg-gray-200'
                  } relative inline-flex flex-shrink-0 h-6 w-11 border-2 border-transparent rounded-full cursor-pointer transition-colors ease-in-out duration-200 focus:outline-none`}
                >
                  <span
                    className={`${
                      lang.is_enabled ? 'translate-x-5' : 'translate-x-0'
                    } pointer-events-none inline-block h-5 w-5 rounded-full bg-white shadow transform ring-0 transition ease-in-out duration-200`}
                  />
                </button>
              </div>
            </li>
          ))}
          {languages.length === 0 && (
            <li className="px-6 py-4 text-sm text-gray-500">No languages found. Ensure database is seeded.</li>
          )}
        </ul>
      </div>
    </div>
  );
}
