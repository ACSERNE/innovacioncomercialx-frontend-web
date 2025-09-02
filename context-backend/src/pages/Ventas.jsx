import React, { useState, useEffect } from 'react';

const Ventas = () => {
  const [ventas, setVentas] = useState([]);
  const [totalComision, setTotalComision] = useState(0);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [loading, setLoading] = useState(false);

  const [fromDate, setFromDate] = useState('');
  const [toDate, setToDate] = useState('');

  const token = localStorage.getItem('token'); // Asumiendo que guardas el token aquí

  const fetchVentas = async (pageNumber = 1) => {
    setLoading(true);
    try {
      const params = new URLSearchParams({ page: pageNumber, limit: 10 });
      if (fromDate) params.append('from', fromDate);
      if (toDate) params.append('to', toDate);

      const res = await fetch(`http://localhost:5001/api/sales?${params.toString()}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await res.json();

      if (res.ok) {
        setVentas(data.sales);
        setTotalComision(data.totalComision);
        setPage(data.page);
        setTotalPages(data.totalPages);
      } else {
        alert(data.error || 'Error al cargar ventas');
      }
    } catch (error) {
      alert('Error de conexión');
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchVentas(page);
  }, []);

  const handleFilter = () => {
    fetchVentas(1);
  };

  return (
    <div>
      <h1>Mis Ventas</h1>

      <div>
        <label>
          Desde:{' '}
          <input type="date" value={fromDate} onChange={e => setFromDate(e.target.value)} />
        </label>
        <label>
          Hasta:{' '}
          <input type="date" value={toDate} onChange={e => setToDate(e.target.value)} />
        </label>
        <button onClick={handleFilter}>Filtrar</button>
      </div>

      <h3>Total comisión: ${totalComision.toFixed(2)}</h3>

      {loading ? (
        <p>Cargando...</p>
      ) : ventas.length === 0 ? (
        <p>No hay ventas para mostrar.</p>
      ) : (
        <table border="1" cellPadding="8" style={{ borderCollapse: 'collapse', marginTop: 10 }}>
          <thead>
            <tr>
              <th>Producto</th>
              <th>Fecha Venta</th>
              <th>Precio Unitario</th>
              <th>Comisión (2.5%)</th>
            </tr>
          </thead>
          <tbody>
            {ventas.map(v => (
              <tr key={v.id}>
                <td>{v.product?.nombre}</td>
                <td>{new Date(v.fecha_venta).toLocaleDateString()}</td>
                <td>${v.product?.precio_unitario.toFixed(2)}</td>
                <td>${v.comision_valor.toFixed(2)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      <div style={{ marginTop: 15 }}>
        <button disabled={page <= 1} onClick={() => fetchVentas(page - 1)}>
          Anterior
        </button>
        <span style={{ margin: '0 10px' }}>
          Página {page} de {totalPages}
        </span>
        <button disabled={page >= totalPages} onClick={() => fetchVentas(page + 1)}>
          Siguiente
        </button>
      </div>
    </div>
  );
};

export default Ventas;
