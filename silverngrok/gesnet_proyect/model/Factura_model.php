<?php 

require_once('Conexion.php');

class FacturaModel extends Conexion
{
    public static function ConsultarFacturas($flagConsulta)
    {
        $dbconec = Conexion::Conectar();
        try {
            $query = "CALL SP_ConsultarVentasFact(:P_FlagConsulta);";
            $stmt = $dbconec->prepare($query);
            $stmt->bindParam(":P_FlagConsulta", $flagConsulta);
            if ($stmt->execute()) {
                $count = $stmt->rowCount();
                if ($count > 0) {
                    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    return json_encode($result);
                } else {
                    return json_encode(['status' => 'empty']);
                }
            } else {
                return json_encode(['status' => 'error']);
            }
        } catch (PDOException $e) {
            error_log("Error PDO: " . $e->getMessage());
            return json_encode(['status' => 'error', 'message' => 'ERROR AL CARGAR LOS DATOS, ConsultarFacturas']);
        } catch (Exception $e) {
            error_log("Error general: " . $e->getMessage());
            return json_encode(['status' => 'error', 'message' => 'ERROR AL CARGAR LOS DATOS, ConsultarFacturas']);
        }
    }
	
	
	public static function ConsultarVentaCredito(){

		$dbconec = Conexion::Conectar();

		try {
			$query = "CALL SP_ConsultarVentasCredito()";
			$stmt = $dbconec->prepare($query);
			if ($stmt->execute()) {
				$count = $stmt->rowCount();
				if ($count > 0) {
					$result = $stmt->fetchAll(PDO::FETCH_ASSOC);
					return json_encode($result);
				} else {
					return json_encode(['status' => 'empty']);
				}
			} else {
				return json_encode(['status' => 'error']);
			}

		} catch (PDOException $e) {
			error_log("Error PDO: " . $e->getMessage());
			return json_encode(['status' => 'error', 'message' => 'ERROR AL CARGAR LOS DATOS, ConsultarVentaCredito']);
		} catch (Exception $e) {
			error_log("Error general: " . $e->getMessage());
			return json_encode(['status' => 'error', 'message' => 'ERROR AL CARGAR LOS DATOS, ConsultarVentaCredito']);
		}

	}


public static function ActualizarVentaFact($p_IdVenta, $p_tipo_pago, $p_tipo_comprobante, $p_pago_efectivo, $p_pago_tarjeta, $p_numero_tarjeta, $p_tarjeta_habiente, $p_cambio, $p_idusuario, $pagado)
{
    try {
        $dbconec = Conexion::Conectar();
        $query = "CALL sp_UpdateVentaFactura(:p_IdVenta, :p_tipo_pago, :p_tipo_comprobante, :p_pago_efectivo, :p_pago_tarjeta, :p_numero_tarjeta, :p_tarjeta_habiente, :p_cambio, :p_idusuario, :pagado)";

        $stmt = $dbconec->prepare($query);
        $stmt->bindParam(":p_IdVenta", $p_IdVenta);
        $stmt->bindParam(":p_tipo_pago", $p_tipo_pago);
        $stmt->bindParam(":p_tipo_comprobante", $p_tipo_comprobante);
        $stmt->bindParam(":p_pago_efectivo", $p_pago_efectivo);
        $stmt->bindParam(":p_pago_tarjeta", $p_pago_tarjeta);
        $stmt->bindParam(":p_numero_tarjeta", $p_numero_tarjeta);
        $stmt->bindParam(":p_tarjeta_habiente", $p_tarjeta_habiente);
        $stmt->bindParam(":p_cambio", $p_cambio);
        $stmt->bindParam(":p_idusuario", $p_idusuario);
		$stmt->bindParam(":pagado", $pagado);

        if ($stmt->execute()) {
            $count = $stmt->rowCount();
            if ($count > 0) {
                $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
                return json_encode($result);
            } else {
                return json_encode(['status' => 'empty']);
            }
        } else {
            $errorInfo = $stmt->errorInfo();
            return json_encode(['status' => 'error', 'message' => 'Error en la ejecución de la consulta: ' . $errorInfo[2]]);
        }
    } catch (PDOException $e) {
        error_log("Error en la consulta: " . $e->getMessage());
        return json_encode(['status' => 'error', 'message' => 'ERROR AL CARGAR LOS DATOS, ActualizarVentaFact', 'detail' => $e->getMessage()]);
    } catch (Exception $e) {
        error_log("Error general: " . $e->getMessage());
        return json_encode(['status' => 'error', 'message' => 'ERROR AL CARGAR LOS DATOS, ActualizarVentaFact', 'detail' => $e->getMessage()]);
    }
}


}

?>
