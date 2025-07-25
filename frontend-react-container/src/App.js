import { BrowserRouter, Routes, Route} from 'react-router-dom';
import MyNavbar from './components/MyNavbar';
import { guestMenu } from './data/differentMenues';
import HomePage from './pages/HomePage';
import AboutPage from './pages/AboutPage';
import CarsPage from './pages/CarsPage';
import NotFoundPage from './pages/NotFoundPage';



function App() {
  return (
    <BrowserRouter>

      <MyNavbar menu={guestMenu}/>





      <Routes>
        <Route path='*' element={<NotFoundPage />} />
        <Route path='/' element={<HomePage />} />
        <Route path='/home' element={<HomePage />} />
        <Route path='/cars' element={<CarsPage />} />
        <Route path='/about' element={<AboutPage />} />


      </Routes>

    </BrowserRouter>
  );
}

export default App;
