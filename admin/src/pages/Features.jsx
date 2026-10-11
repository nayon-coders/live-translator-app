import { useEffect, useState } from 'react';
import { api } from '../store/useAuthStore';
import { Loader2 } from 'lucide-react';

export default function Features() {
  const [features, setFeatures] = useState([]);
  const [loading, setLoading] = useState(true);
  const [savingId, setSavingId] = useState(null);

  useEffect(() => {
    fetchFeatures();
  }, []);

  const fetchFeatures = async () => {
    try {
      const { data } = await api.get('/features');
      setFeatures(data.data || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const toggleFeature = async (feature) => {
    setSavingId(feature.key);
    try {
      await api.patch(`/features/${feature.key}`, { is_enabled: !feature.is_enabled });
      // Update local state
      setFeatures(features.map(f => f.key === feature.key ? { ...f, is_enabled: !feature.is_enabled } : f));
    } catch (err) {
      alert('Failed to update feature');
    } finally {
      setSavingId(null);
    }
  };

  if (loading) {
    return <div className="flex justify-center p-8"><Loader2 className="w-8 h-8 animate-spin text-primary-500" /></div>;
  }

  return (
    <div>
      <h1 className="text-2xl font-semibold text-gray-900 mb-6">App Features</h1>
      
      <div className="bg-white shadow overflow-hidden sm:rounded-md">
        <ul role="list" className="divide-y divide-gray-200">
          {features.map((feature) => (
            <li key={feature.key} className="px-6 py-4 flex items-center justify-between hover:bg-gray-50">
              <div>
                <p className="text-sm font-medium text-gray-900">{feature.name}</p>
                <p className="text-sm text-gray-500">{feature.key}</p>
              </div>
              
              <div className="flex items-center">
                <span className="mr-3 text-sm text-gray-500">
                  {feature.is_enabled ? 'Enabled' : 'Disabled'}
                </span>
                
                <button
                  onClick={() => toggleFeature(feature)}
                  disabled={savingId === feature.key}
                  className={`${
                    feature.is_enabled ? 'bg-primary-600' : 'bg-gray-200'
                  } relative inline-flex flex-shrink-0 h-6 w-11 border-2 border-transparent rounded-full cursor-pointer transition-colors ease-in-out duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500`}
                >
                  <span className="sr-only">Toggle feature</span>
                  <span
                    aria-hidden="true"
                    className={`${
                      feature.is_enabled ? 'translate-x-5' : 'translate-x-0'
                    } pointer-events-none inline-block h-5 w-5 rounded-full bg-white shadow transform ring-0 transition ease-in-out duration-200`}
                  />
                </button>
              </div>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
