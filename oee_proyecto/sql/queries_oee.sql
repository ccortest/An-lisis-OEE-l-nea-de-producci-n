-- 1. Disponibilidad por turno
SELECT
    p.fecha,
    p.turno,
    ROUND((480 - COALESCE(SUM(par.tiempo_min), 0)) * 1.0 / 480, 3) AS disponibilidad
FROM produccion p
LEFT JOIN paradas par ON p.fecha = par.fecha AND p.turno = par.turno
GROUP BY p.fecha, p.turno;

-- 2. Rendimiento por turno
SELECT
    fecha,
    turno,
    ROUND(SUM(prod_real) * 1.0 / SUM(prod_teorica), 3) AS rendimiento
FROM produccion
GROUP BY fecha, turno;

-- 3. Calidad por turno
SELECT
    fecha,
    turno,
    ROUND(SUM(unidades_tot - defectuosas) * 1.0 / SUM(unidades_tot), 3) AS calidad
FROM defectos
GROUP BY fecha, turno;

-- 4. OEE final (juntando las 3 anteriores)
SELECT
    disp.fecha,
    disp.turno,
    disp.disponibilidad,
    rend.rendimiento,
    cal.calidad,
    ROUND(disp.disponibilidad * rend.rendimiento * cal.calidad, 3) AS oee
FROM (
    SELECT
        p.fecha,
        p.turno,
        ROUND((480 - COALESCE(SUM(par.tiempo_min), 0)) * 1.0 / 480, 3) AS disponibilidad
    FROM produccion p
    LEFT JOIN paradas par ON p.fecha = par.fecha AND p.turno = par.turno
    GROUP BY p.fecha, p.turno
) disp
JOIN (
    SELECT
        fecha,
        turno,
        ROUND(SUM(prod_real) * 1.0 / SUM(prod_teorica), 3) AS rendimiento
    FROM produccion
    GROUP BY fecha, turno
) rend ON disp.fecha = rend.fecha AND disp.turno = rend.turno
JOIN (
    SELECT
        fecha,
        turno,
        ROUND(SUM(unidades_tot - defectuosas) * 1.0 / SUM(unidades_tot), 3) AS calidad
    FROM defectos
    GROUP BY fecha, turno
) cal ON disp.fecha = cal.fecha AND disp.turno = cal.turno;