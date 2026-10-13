INSERT INTO usuarios (username, password_hash, nombre, rol) VALUES
('admin',   crypt('Admin123*',   gen_salt('bf', 10)), 'Administrador', 'ADMIN'),
('tendero', crypt('Tendero123*', gen_salt('bf', 10)), 'Tendero',       'TENDERO');