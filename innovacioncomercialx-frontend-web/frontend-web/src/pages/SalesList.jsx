import React, { useState, useEffect } from 'react';
import axios from 'axios';

const SalesList = ({ token }) => {
  const [sales, setSales] = useState([]);
  const [totalComision, setTotalComision] = useState(0);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [fromDate, setFromDate] = useState('');
  const [toDate, setToDate] = useState('');
  const [loading, setLoading] = useState(false);

  const fetchSales = async () => {
    setLoading(true);
    try {
      const params = {
        page,
        limit: 10,
      };
      if (fromDate) params.from = fromDate;
      if (toDate) params.to = toDate;

      const res = await axios.get('http://localhost:5001/api/sales/mine', {
        headers: {
          Authorization: `Bearer ${token}`,
        },
        params,
      });
      setSales(res.data.sales);
      setTotalComision(res.data.totalComision);
      setTotalPages(res.data.totalPages);
    } catch (error) {
      console.error('Error al cargar ventas:', error);
      alert('Error cargando las ventas.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSales();
  }, [page, fromDate, toDate]);

  return (
    <div style={{ maxWidth: 800, margin: 'auto' }}>
      <h2>Mis Ventas</h2>

      <div style={{ marginBottom: 20 }}>
        <label>
          Desde: <input type="date" value={fromDate} onChange={e => setFromDate(e.target.value)} />
        </label>{' '}
        <label>
          Hasta: <input type="date" value={toDate} onChange={e => setToDate(e.target.value)} />
        </label>
      </div>

      {loading ? (
        <p>Cargando...</p>
      ) : (
        <>
          <table border="1" cellPadding="8" cellSpacing="0" width="100%">
            <thead>
              <tr>
                <th>Producto</th>
                <th>Fecha de Venta</th>
                <th>Cantidad</th>
                <th>Precio Unitario</th>
                <th>Valor Comisión</th>
              </tr>
            </thead>
            <tbody>
              {sales.length === 0 ? (
                <tr>
                  <td colSpan="5" style={{ textAlign: 'center' }}>
                    No hay ventas.
                  </td>
                </tr>
              ) : (
                sales.map(sale => (
                  <tr key={sale.id}>
                    <td>{sale.product?.nombre || 'N/A'}</td>
                    <td>{new Date(sale.fecha_venta).toLocaleDateString()}</td>
                    <td>{sale.cantidad}</td>
                    <td>{sale.product?.precio_unitario.toFixed(2)}</td>
                    <td>{sale.comision_valor.toFixed(2)}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>

          <p style={{ marginTop: 10 }}>
            <strong>Total Comisión:</strong> ${totalComision.toFixed(2)}
          </p>

          <div style={{ marginTop: 20 }}>
            <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1}>
              Anterior
            </button>{' '}
            <button onClick={() => setPage(p => Math.min(totalPages, p + 1))} disabled={page === totalPages}>
              Siguiente
            </button>
            <span style={{ marginLeft: 10 }}>
              Página {page} de {totalPages}
            </span>
          </div>
        </>
      )}
    </div>
  );
};

export default SalesList;
