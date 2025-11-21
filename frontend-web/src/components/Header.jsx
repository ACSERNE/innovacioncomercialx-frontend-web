import React from 'react';
import { Link } from 'react-router-dom';

const Header = () => {
  return (
    <header style={styles.header}>
      <nav style={styles.nav}>
        <Link to="/" style={styles.link}>Inicio</Link>
        <Link to="/ventas" style={styles.link}>Ventas</Link>
        <Link to="/login" style={styles.link}>Login</Link>
      </nav>
    </header>
  );
};

const styles = {
  header: {
    backgroundColor: '#007bff',
    padding: '10px 20px',
    color: 'white',
  },
  nav: {
    display: 'flex',
    gap: '20px',
  },
  link: {
    color: 'white',
    textDecoration: 'none',
    fontWeight: 'bold',
  },
};

export default Header;
