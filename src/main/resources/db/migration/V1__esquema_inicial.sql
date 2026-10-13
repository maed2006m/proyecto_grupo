CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE usuarios (
    id            BIGSERIAL PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password_hash VARCHAR(100) NOT NULL,
    nombre        VARCHAR(120) NOT NULL,
    rol           VARCHAR(20)  NOT NULL CHECK (rol IN ('TENDERO', 'ADMIN')),
    activo        BOOLEAN      NOT NULL DEFAULT TRUE,
    creado_en     TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE proveedores (
    id                  BIGSERIAL PRIMARY KEY,
    nombre              VARCHAR(120) NOT NULL,
    nit                 VARCHAR(20)  NOT NULL UNIQUE,
    telefono            VARCHAR(20),
    email               VARCHAR(120),
    direccion           VARCHAR(200),
    tiempo_entrega_dias INT          NOT NULL DEFAULT 2 CHECK (tiempo_entrega_dias >= 0),
    activo              BOOLEAN      NOT NULL DEFAULT TRUE,
    creado_en           TIMESTAMPTZ  NOT NULL DEFAULT now(),
    actualizado_en      TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE productos (
    id             BIGSERIAL PRIMARY KEY,
    sku            VARCHAR(30)   NOT NULL UNIQUE,
    nombre         VARCHAR(120)  NOT NULL,
    categoria      VARCHAR(60),
    unidad         VARCHAR(20)   NOT NULL DEFAULT 'UNIDAD',
    proveedor_id   BIGINT        NOT NULL REFERENCES proveedores(id),
    stock_minimo   INT           NOT NULL CHECK (stock_minimo >= 0),
    costo_unitario NUMERIC(12,2) NOT NULL CHECK (costo_unitario >= 0),
    precio_venta   NUMERIC(12,2) NOT NULL CHECK (precio_venta >= 0),
    activo         BOOLEAN       NOT NULL DEFAULT TRUE,
    creado_en      TIMESTAMPTZ   NOT NULL DEFAULT now(),
    actualizado_en TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE TABLE movimientos (
    id             BIGSERIAL PRIMARY KEY,
    producto_id    BIGINT        NOT NULL REFERENCES productos(id),
    tipo           VARCHAR(10)   NOT NULL CHECK (tipo IN ('ENTRADA', 'SALIDA')),
    motivo         VARCHAR(20)   NOT NULL CHECK (motivo IN ('COMPRA', 'VENTA', 'AVERIA', 'VENCIMIENTO')),
    cantidad       INT           NOT NULL CHECK (cantidad > 0),
    valor_unitario NUMERIC(12,2) NOT NULL CHECK (valor_unitario >= 0),
    observacion    VARCHAR(250),
    usuario_id     BIGINT        NOT NULL REFERENCES usuarios(id),
    fecha          TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CONSTRAINT ck_tipo_motivo CHECK (
        (tipo = 'ENTRADA' AND motivo = 'COMPRA') OR
        (tipo = 'SALIDA'  AND motivo IN ('VENTA', 'AVERIA', 'VENCIMIENTO'))
    )
);

CREATE INDEX idx_mov_producto_fecha ON movimientos (producto_id, fecha);
CREATE INDEX idx_mov_fecha          ON movimientos (fecha);
CREATE INDEX idx_prod_proveedor     ON productos (proveedor_id);

-- Existencia = entradas - salidas (RF-20, RNF-05)
CREATE VIEW v_stock_producto AS
SELECT p.id AS producto_id,
       COALESCE(SUM(CASE WHEN m.tipo = 'ENTRADA' THEN m.cantidad ELSE -m.cantidad END), 0) AS existencia
FROM productos p
LEFT JOIN movimientos m ON m.producto_id = p.id
GROUP BY p.id;

-- RNF-04: los movimientos no se editan ni se borran
CREATE FUNCTION fn_movimientos_inmutables() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Los movimientos son inmutables (RNF-04)';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_movimientos_inmutables
BEFORE UPDATE OR DELETE ON movimientos
FOR EACH ROW EXECUTE FUNCTION fn_movimientos_inmutables();

-- RF-21: defensa en profundidad, una salida nunca deja existencia negativa
CREATE FUNCTION fn_validar_salida() RETURNS trigger AS $$
DECLARE
    disponible INT;
BEGIN
    IF NEW.tipo = 'SALIDA' THEN
        PERFORM 1 FROM productos WHERE id = NEW.producto_id FOR UPDATE;
        SELECT existencia INTO disponible FROM v_stock_producto WHERE producto_id = NEW.producto_id;
        IF NEW.cantidad > disponible THEN
            RAISE EXCEPTION 'Existencia insuficiente: disponible %, solicitado %', disponible, NEW.cantidad;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_salida
BEFORE INSERT ON movimientos
FOR EACH ROW EXECUTE FUNCTION fn_validar_salida();