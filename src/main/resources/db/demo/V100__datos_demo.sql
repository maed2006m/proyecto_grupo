INSERT INTO proveedores (nombre, nit, telefono, email, tiempo_entrega_dias) VALUES
('Distribuidora Andina', '900100001-1', '3001110001', 'ventas@andina.example',   2),
('Lácteos del Valle',    '900100002-2', '3001110002', 'pedidos@valle.example',   1),
('Bebidas Capital',      '900100003-3', '3001110003', 'comercial@capital.example', 3),
('Aseo Hogar S.A.S.',    '900100004-4', '3001110004', 'info@aseohogar.example',  4),
('Granos y Abarrotes',   '900100005-5', '3001110005', 'ventas@granos.example',   2);

INSERT INTO productos (sku, nombre, categoria, proveedor_id, stock_minimo, costo_unitario, precio_venta) VALUES
('ARR-001', 'Arroz 500 g',        'Granos',   5, 20, 1800, 2400),
('LEN-001', 'Lentejas 500 g',     'Granos',   5, 10, 2200, 3000),
('ACE-001', 'Aceite 1 L',         'Abarrotes',1, 12, 9000, 11500),
('AZU-001', 'Azúcar 1 kg',        'Abarrotes',1, 15, 3300, 4200),
('LEC-001', 'Leche entera 1 L',   'Lácteos',  2, 30, 3100, 3900),
('YOG-001', 'Yogur 200 g',        'Lácteos',  2, 15, 1500, 2200),
('QUE-001', 'Queso campesino',    'Lácteos',  2,  8, 6500, 8500),
('GAS-001', 'Gaseosa 1.5 L',      'Bebidas',  3, 24, 3800, 5000),
('AGU-001', 'Agua 600 ml',        'Bebidas',  3, 24,  900, 1500),
('CER-001', 'Cerveza lata',       'Bebidas',  3, 24, 2300, 3200),
('DET-001', 'Detergente 1 kg',    'Aseo',     4, 10, 7800, 9800),
('JAB-001', 'Jabón de barra',     'Aseo',     4, 12, 1400, 2000);

-- Compra inicial hace 90 días y reposiciones cada 15 días
INSERT INTO movimientos (producto_id, tipo, motivo, cantidad, valor_unitario, usuario_id, fecha)
SELECT p.id, 'ENTRADA', 'COMPRA', CASE WHEN d = 0 THEN 150 ELSE 100 END,
       p.costo_unitario, 2, now() - make_interval(days => 90 - d)
FROM productos p CROSS JOIN generate_series(0, 75, 15) AS d;

-- Ventas diarias: probabilidad 0.7, cantidad 1 a 6, el doble viernes y sábado
INSERT INTO movimientos (producto_id, tipo, motivo, cantidad, valor_unitario, usuario_id, fecha)
SELECT p.id, 'SALIDA', 'VENTA',
       (1 + floor(random() * 6))::int * CASE WHEN extract(dow FROM d) IN (5, 6) THEN 2 ELSE 1 END,
       p.precio_venta, 2, d
FROM productos p
CROSS JOIN generate_series(now() - interval '89 days', now() - interval '1 day', interval '1 day') AS d
WHERE random() < 0.7;