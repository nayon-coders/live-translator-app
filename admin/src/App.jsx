import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Features from './pages/Features';
import Languages from './pages/Languages';
import Settings from './pages/Settings';
import GlobalSettings from './pages/GlobalSettings';
import PracticeModes from './pages/PracticeModes';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/" element={<Layout />}>
          <Route index element={<Dashboard />} />
          <Route path="/features" element={<Features />} />
          <Route path="/languages" element={<Languages />} />
          <Route path="/practice-modes" element={<PracticeModes />} />
          <Route path="/gemini" element={<Settings />} />
          <Route path="/settings" element={<GlobalSettings />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
