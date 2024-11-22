<?php
// Habilitar la visualización de errores
session_start();
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');

$response = ["success" => false, "message" => ""];

if(isset($_FILES['archivo_csv']['tmp_name'])) {
    $archivo_temporal = $_FILES['archivo_csv']['tmp_name'];

    function importarCSV($archivo_temporal) {
        $response = ["success" => false, "message" => ""];

        if(($archivo = fopen($archivo_temporal, "r")) !== FALSE) {
            include '../../model/Conexion.php';
            $conexion = Conexion::Conectar();

            while(($datos = fgetcsv($archivo, 1000, ",")) !== FALSE) {
                $idproducto = $datos[0];
                $codigo_interno = $datos[1];
                $codigo_barra = $datos[2];
                $codigo_alternativo = $datos[3];
                $nombre_producto = $datos[4];
                $precio_compra = $datos[5];
                $precio_venta = $datos[6];
                $precio_venta1 = $datos[7];
                $precio_venta2 = $datos[8];
                $precio_venta3 = $datos[9];
                $precio_venta_mayoreo = $datos[10];
                $stock = $datos[11];
                $stock_min = $datos[12];
                $idcategoria = $datos[13];
                $idmarca = $datos[14];
                $idpresentacion = $datos[15];
                $estado = $datos[16];
                $exento = $datos[17];
                $inventariable = $datos[18];
                $perecedero = $datos[19];
                $imagen = $datos[20];
                $usuario = $datos[21];

                $usuario = $_SESSION['user_id'];

                $sql = "INSERT INTO producto (idproducto, codigo_interno, codigo_barra, codigo_alternativo, nombre_producto, precio_compra, precio_venta, precio_venta1, precio_venta2, precio_venta3, precio_venta_mayoreo, stock, stock_min, idcategoria, idmarca, idpresentacion, estado, exento, inventariable, perecedero, imagen, usuario) VALUES ('$idproducto', '$codigo_interno', '$codigo_barra', '$codigo_alternativo', '$nombre_producto', '$precio_compra', '$precio_venta', '$precio_venta1', '$precio_venta2', '$precio_venta3','$precio_venta_mayoreo', '$stock', '$stock_min', '$idcategoria', '$idmarca', '$idpresentacion', '$estado', '$exento', '$inventariable', '$perecedero', '$imagen', '$usuario')";
                if ($conexion->query($sql) == TRUE) {
                    $response["success"] = true;
                    $response["message"] = "Registro insertado correctamente.";
                } else {
                    $response["success"] = false;
                    $response["message"] = "Error al insertar el registro: " . $conexion->error;
                }
            }

            fclose($archivo);
            unset($conexion);
        } else {
            $response["message"] = "Error al abrir el archivo CSV.";
        }

        return json_encode($response);
    }

    echo importarCSV($archivo_temporal);
} else {
    echo json_encode(["success" => false, "message" => "Error: No se proporcionó un archivo CSV."]);
}
?>


