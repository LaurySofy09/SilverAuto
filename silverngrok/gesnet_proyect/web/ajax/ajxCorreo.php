<?php
session_start();
// Inicializar la variable de respuesta
$response = array();
// Recuperar el contenido del PDF desde la sesión

if (isset($_SESSION['numero_comprobante'])) {

    $nombreArchivoPDF = $_SESSION['nombreArchivoPDF'];
    $p_idcliente = $_SESSION['p_idcliente'];
    $p_nombre_cliente = $_SESSION['p_nombre_cliente'];
    $email = $_SESSION['p_email'];
    $numero_comprobante = $_SESSION['numero_comprobante'];
    // Dirección de correo electrónico del destinatario
	$destinatario = $email;
	// Asunto del correo electrónico
	$asunto = 'Factura Silver AutoPartes';

    $rutaCompletaPDF  = $_SERVER['DOCUMENT_ROOT'] . '/silverngrok/gesnet_proyect/reportes/Tickets/' . $nombreArchivoPDF;

    if (file_exists($rutaCompletaPDF)) {
        // El archivo existe, continúa con el proceso.

        // Mensaje de texto plano
        //$mensajeTextoPlano = 'Soy un Crack.';

        // Mensaje completo del correo
        $mensajeCorreo = "--boundary\r\n";
        $mensajeCorreo .= "Content-type: text/plain; charset=utf-8\r\n";
        $mensajeCorreo .= "Content-Transfer-Encoding: 7bit\r\n";
        $mensajeCorreo .= "\r\n";
        $mensajeCorreo .= 'Hola '. $p_nombre_cliente . "\r\n";
		$mensajeCorreo .= "Le hemos adjuntado su factura." . "\r\n";
		$mensajeCorreo .= "Gracias por preferirnos." . "\r\n";
        // Adjuntar el archivo PDF
        $mensajeCorreo .= "--boundary\r\n";
        $mensajeCorreo .= "Content-Type: application/pdf; name=\"$nombreArchivoPDF\"\r\n";
        $mensajeCorreo .= "Content-Transfer-Encoding: base64\r\n";
        $mensajeCorreo .= "Content-Disposition: attachment; filename=\"$nombreArchivoPDF\"\r\n";
        $mensajeCorreo .= "\r\n";

        // Verificar el tamaño del archivo antes de adjuntarlo
        if (filesize($rutaCompletaPDF) > 0) {
            try {
                $archivo = fopen($rutaCompletaPDF, 'rb');
                $contenido = null;

                if ($archivo) {
                    $contenido = fread($archivo, filesize($rutaCompletaPDF));
                    fclose($archivo);

                    // Adjuntar el archivo PDF
                    $mensajeCorreo .= chunk_split(base64_encode($contenido)) . "\r\n";
                    $mensajeCorreo .= "--boundary--";

                    // Encabezados del correo
                    $headers = "From: tommiguel93@gmail.com\r\n";
                    $headers .= "MIME-Version: 1.0\r\n";
                    $headers .= 'Content-Type: multipart/mixed; boundary="boundary"' . "\r\n";

                    // Enviar el correo electrónico
                    error_reporting(E_ALL);
                    ini_set('display_errors', 1);
                    $retval = mail($destinatario, $asunto, $mensajeCorreo, $headers);

                    // Verificar si el correo se envió correctamente
                    if ($retval) {
                        $response[] = array("status" => 'success', "message" => 'Correo enviado correctamente.');
                    } else {
                        // Escribir mensaje de error en el registro de errores
                         	$lastError = error_get_last();
    						var_dump($lastError);
                        error_log('Error al enviar el correo electrónico. lastError: ' . print_r($lastError, true));
                        $response[] = array("status" => 'error', "message" => 'Error al enviar el correo electrónico.', 'retval' => $retval, 'destinatario' => $destinatario, "asunto" => $asunto, "mensajeCorreo" => $mensajeCorreo, "headers" => $headers);
                    }
                } else {
                    $response[] = array("status" => 'error', "message" => 'Error al abrir el archivo: ' . $archivo);
                }
            } catch (Exception $e) {
                // Escribir mensaje de error en el registro de errores
                error_log('Error al enviar el correo electrónico. Error: ' . $e->getMessage());
                $response[] = array("status" => 'error', "message" => 'Error al enviar el correo electrónico. Error: ' . $e->getMessage());
            }
        } else {
            $response[] = array("status" => 'error', "message" => 'Error tamaño del archivo: ' . filesize($rutaCompletaPDF));
        }

        // Limpiar la variable de sesión después de usarla
        unset($_SESSION['p_idcliente']);
        unset($_SESSION['p_nombre_cliente']);
        unset($_SESSION['p_email']);
        unset($_SESSION['numero_comprobante']);

        // Enviar la respuesta como JSON
        echo json_encode($response);
    } else {
        $response[] = array("status" => 'error', "message" => 'Error con la ruta : ' . $rutaCompletaPDF);
        echo json_encode($response);
    }
} else {
    $response[] = array("status" => 'error', "message" => 'Error con la session');
    echo json_encode($response);
}
?>
