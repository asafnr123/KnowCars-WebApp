import { BrowserRouter, Routes, Route, Link, useParams } from 'react-router-dom';
import MyNavbar from './components/MyNavbar';
import { guestMenu } from './data/differentMenues';
import HomePage from './pages/HomePage';
import AboutPage from './pages/AboutPage';



function App() {
  return (
    <BrowserRouter>

      <MyNavbar menu={guestMenu}/>

      <Routes>
        <Route path='*' element={<h1>ERROR 404</h1> } />
        <Route path='/' element={<HomePage />} />
        <Route path='/home' element={<HomePage />} />
        <Route path='/about' element={<AboutPage />} />


      </Routes>

    </BrowserRouter>
  );
}

export default App;
