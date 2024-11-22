<?php
// Conexión a la base de datos
include 'C:\xampp\htdocs\silverngrok\gesnet_proyect\model\Conexion.php';

$conexion = Conexion::Conectar();

// Nombre del archivo CSV
$archivo_csv = 'exportacion_inventario.csv';

// Consulta para obtener los datos de la tabla
$sql = "SELECT * FROM view_productos";
$resultado = $conexion->query($sql);

if ($resultado->rowCount() > 0) {
    // Abrir el archivo CSV para escritura
    $archivo = fopen($archivo_csv, 'w');

    // Escribir los encabezados de las columnas en el archivo CSV
    $columnas = array();
    foreach ($resultado->fetch(PDO::FETCH_ASSOC) as $columna => $valor) {
        $columnas[] = $columna;
    }
    fputcsv($archivo, $columnas);

    // Rebobinar el cursor del resultado
    $resultado->execute();

    // Escribir los datos de la tabla en el archivo CSV
    while ($fila = $resultado->fetch(PDO::FETCH_ASSOC)) {
        fputcsv($archivo, $fila);
    }

    // Cerrar el archivo CSV
    fclose($archivo);

    // Cabeceras para descargar el archivo
    header('Content-Type: application/csv');
    header('Content-Disposition: attachment; filename="' . $archivo_csv . '"');
    readfile($archivo_csv);

    // Eliminar el archivo CSV después de descargarlo
    unlink($archivo_csv);
} else {
    echo "No se encontraron datos en la tabla.";
}

// Cerrar la conexión a la base de datos
$conexion = null;
?>

