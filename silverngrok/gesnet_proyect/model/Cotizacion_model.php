<?php

	require_once('Conexion.php');

	class CotizacionModel extends Conexion
	{

		public static function Autocomplete_Producto($search){

		 try {

		 $sugg_json = array();    // this is for displaying json data as a autosearch suggestion
		 $json_row = array();     // this is for stroring mysql results in json string

		 $keyword = preg_replace('/\s+/', ' ', $search); // it will replace multiple spaces from the input.

		 $query = "CALL sp_search_producto_cotizacion(:search)";
		 $stmt = Conexion::Conectar()->prepare($query);
		 $stmt->bindParam(":search", $keyword);
		 $stmt->execute();

		 if ($stmt->rowCount() > 0){

		 while($recResult = $stmt->fetch(PDO::FETCH_ASSOC)) {

			 $json_row["value"] = $recResult['idproducto'];
			 $json_row["label"] = $recResult['codigo_interno'].' - '.$recResult['codigo_barra'].' - '.$recResult['nombre_producto'];
			 $json_row["producto"] = $recResult['nombre_producto'];
			 $json_row["precio_venta"] = $recResult['precio_venta'];
			 $json_row["precio_venta1"] = $recResult['precio_venta1'];
			 $json_row["precio_venta2"] = $recResult['precio_venta2'];
			 $json_row["precio_venta3"] = $recResult['precio_venta3'];
			 $json_row["precio_venta_mayoreo"] = $recResult['precio_venta_mayoreo'];
			 $json_row["stock"] = $recResult['stock'];
			 $json_row["exento"] = $recResult['exento'];
			 $json_row["datos"] = $recResult['nombre_marca'].' - '.$recResult['siglas'];

			 array_push($sugg_json, $json_row);
		 }

		 } else {

			 $json_row["value"] = "";
			 $json_row["label"] = "";
			 $json_row["datos"] = "";
			 array_push($sugg_json, $json_row);
		 }


			$jsonOutput = json_encode($sugg_json, JSON_UNESCAPED_SLASHES);
			print $jsonOutput;


		 } catch (Exception $e) {

			 echo "Error al cargar el listado";
		 }

		 }

		public static function Ver_Moneda_Reporte(){

			$dbconec = Conexion::Conectar();

			try {
				$query = "CALL sp_view_money()";
				$stmt = $dbconec->prepare($query);
				$stmt->execute();
				$count = $stmt->rowCount();

				if($count > 0)
				{
					return $stmt->fetchAll();
				}


				$dbconec = null;

			} catch (Exception $e) {

				echo "Error al cargar el listado";
			}

		}

    public static function Listar_Cotizaciones($date,$date2)
    {
      $dbconec = Conexion::Conectar();

      try
      {
        $query = "CALL sp_view_cotizacion(:date,:date2);";
        $stmt = $dbconec->prepare($query);
        $stmt->bindParam(":date",$date);
        $stmt->bindParam(":date2",$date2);
        $stmt->execute();
        $count = $stmt->rowCount();

        if($count > 0)
        {
          return $stmt->fetchAll();
        }


        $dbconec = null;
      } catch (Exception $e) {

        echo '<span class="label label-danger label-block">ERROR AL CARGAR LOS DATOS, PRESIONE F5</span>';
      }
    }


		public static function Listar_Detalle($idcotizacion)
		{
			$dbconec = Conexion::Conectar();

			try
			{
				$query = "CALL sp_view_cotizacion_detalle(:idcotizacion);";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":idcotizacion",$idcotizacion);
				$stmt->execute();
				$count = $stmt->rowCount();

				if($count > 0)
				{
					return $stmt->fetchAll();
				}


				$dbconec = null;
			} catch (Exception $e) {

				echo '<span class="label label-danger label-block">ERROR AL CARGAR LOS DATOS, PRESIONE F5</span>';
			}
		}

		public static function Listar_Objetos($idcotizacion)
		{
			$dbconec = Conexion::Conectar();

			try
			{
				$query = "CALL sp_view_cotizacion_objetos(:idcotizacion);";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":idcotizacion",$idcotizacion);
				$stmt->execute();
				$count = $stmt->rowCount();

				if($count > 0)
				{
					return $stmt->fetchAll();
				}


				$dbconec = null;
			} catch (Exception $e) {

				echo '<span class="label label-danger label-block">ERROR AL CARGAR LOS DATOS, PRESIONE F5</span>';
			}
		}

		public static function Listar_Info($idcotizacion)
		{
			$dbconec = Conexion::Conectar();

			try
			{
				$query = "CALL sp_view_info_cotizacion(:idcotizacion);";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":idcotizacion",$idcotizacion);
				$stmt->execute();
				$count = $stmt->rowCount();

				if($count > 0)
				{
					return $stmt->fetchAll();
				}


				$dbconec = null;
			} catch (Exception $e) {

				echo '<span class="label label-danger label-block">ERROR AL CARGAR LOS DATOS, PRESIONE F5</span>';
			}
		}
		
		
		public static function ActualizarCotizacionFactura($P_IdCotizacion)
		{
        $dbconec = Conexion::Conectar();
        try {
            $query = "CALL sp_UpdateCotizaFact(:P_IdCotizacion);";
            $stmt = $dbconec->prepare($query);
            $stmt->bindParam(":P_IdCotizacion", $P_IdCotizacion);
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
            return json_encode(['status' => 'error', 'message' => 'ERROR AL CARGAR LOS DATOS, PRESIONE F5']);
        } catch (Exception $e) {
            error_log("Error general: " . $e->getMessage());
            return json_encode(['status' => 'error', 'message' => 'ERROR AL CARGAR LOS DATOS, PRESIONE F5']);
        }
		}

		public static function Insertar_Cotizacion($a_nombre, $tipo_pago, $entrega,
		$sumas, $iva, $exento, $retenido, $descuento, $total, $sonletras, $idusuario, $idcliente)
		{
			$dbconec = Conexion::Conectar();
			try
			{
				$query = "CALL sp_insert_cotizacion(:a_nombre, :tipo_pago, :entrega,
        :sumas, :iva, :exento, :retenido, :descuento, :total, :sonletras, :idusuario, :idcliente)";
				$stmt = $dbconec->prepare($query);
        $stmt->bindParam(":a_nombre",$a_nombre);
				$stmt->bindParam(":tipo_pago",$tipo_pago);
				$stmt->bindParam(":entrega",$entrega);
				$stmt->bindParam(":sumas",$sumas);
				$stmt->bindParam(":iva",$iva);
				$stmt->bindParam(":exento",$exento);
				$stmt->bindParam(":retenido",$retenido);
				$stmt->bindParam(":descuento",$descuento);
				$stmt->bindParam(":total",$total);
				$stmt->bindParam(":sonletras",$sonletras);
                $stmt->bindParam(":idusuario",$idusuario);
				$stmt->bindParam(":idcliente",$idcliente);

				if($stmt->execute())
				{
					$count = $stmt->rowCount();
					if($count == 0){
						$data = "Duplicado";
 	   					echo json_encode($data);
					} else {
						$data = "Validado";
 	   					echo json_encode($data);
					}
				} else {

					$data = "Error_Cotizacion";
 	   		 	 	echo json_encode($data);
				}
				$dbconec = null;
			} catch (Exception $e) {
				$data = "Error_Cotizacion";
				echo json_encode($data);

			}

		}

		public static function Borrar_Cotizacion($idcotizacion)
		{
			$dbconec = Conexion::Conectar();
			$response = array();
			try
			{
				$query = "CALL sp_delete_cotizacion(:idcotizacion)";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":idcotizacion",$idcotizacion);

				if($stmt->execute())
				{
					$response['status']  = 'success';
					$response['message'] = 'Cotizacion Eliminada Correctamente!';
				} else {

					$response['status']  = 'error';
					$response['message'] = 'No pudimos eliminar la Cotizacion!';
				}
				echo json_encode($response);
				$dbconec = null;
			} catch (Exception $e) {
				$response['status']  = 'error';
				$response['message'] = 'Error de Ejecucion';
				echo json_encode($response);

			}

		}

		public static function Insertar_DetalleCotizacion($idproducto, $cantidad, $disponible, $precio_unitario, $exento, $descuento, $importe){

			try {

				$query = "CALL sp_insert_detallecotizacion(:idproducto, :cantidad, :disponible, :precio_unitario, :exento, :descuento, :importe)";

				$stmt = Conexion::Conectar()->prepare($query);
		   		$stmt->bindParam(":idproducto",$idproducto);
		   		$stmt->bindParam(":cantidad",$cantidad);
				$stmt->bindParam(":disponible",$disponible);
		   		$stmt->bindParam(":precio_unitario",$precio_unitario);
		   		$stmt->bindParam(":exento",$exento);
		   		$stmt->bindParam(":descuento",$descuento);
		   		$stmt->bindParam(":importe",$importe);

				$stmt->execute();

				$dbconec = null;

			} catch (Exception $e) {
					echo $e;
				 //$data = "Error";
 	   		 //echo json_encode($data);
			}

		}


		public static function Count_Cotizaciones($date,$date2)
		{
			$dbconec = Conexion::Conectar();

			try
			{
				$query = "CALL sp_count_cotizaciones(:date,:date2);";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":date",$date);
				$stmt->bindParam(":date2",$date2);
				$stmt->execute();
				$count = $stmt->rowCount();

				if($count > 0)
				{
					return $stmt->fetchAll();
				}


				$dbconec = null;
			} catch (Exception $e) {

				echo '<span class="label label-danger label-block">ERROR AL CARGAR LOS DATOS, PRESIONE F5</span>';
			}
		}

		public static function Mostrar_Cliente($idCotizacion)
		{
			$dbconec = Conexion::Conectar();

			try
			{
				$query = "CALL sp_view_ddl_cotizacion(:idCotizacion);";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":idCotizacion",$idCotizacion);
				$stmt->execute();
				$count = $stmt->rowCount();

				if($count > 0)
				{
					return $stmt->fetchAll();
				}


				$dbconec = null;
			} catch (Exception $e) {

				echo '<span class="label label-danger label-block">ERROR AL CARGAR EL CLIENTE</span>';
			}
		}

		public static function Ver_Limite_Credito($idcliente){

			$dbconec = Conexion::Conectar();
			try {

				$query = "CALL sp_view_limite_credito(:idcliente)";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":idcliente",$idcliente);
				$stmt->execute();
				$Data = array();

				while($row=$stmt->fetch(PDO::FETCH_ASSOC)){
						$Data[] = $row;
				}

				// header('Content-type: application/json');
				 echo json_encode($Data);

			} catch (Exception $e) {

				echo "Error al cargar el listado";
			}

		}

		public static function Insertar_Venta($tipo_pago, $tipo_comprobante,
		$sumas, $iva, $exento, $retenido, $descuento, $total, $sonletras, $pago_efectivo, $pago_tarjeta, $numero_tarjeta,
		$tarjeta_habiente, $cambio, $estado, $idcliente, $idusuario)
		{
			$dbconec = Conexion::Conectar();
			try
			{
				$query = "CALL sp_insert_venta(:tipo_pago, :tipo_comprobante,
				:sumas, :iva, :exento, :retenido, :descuento, :total, :sonletras, :pago_efectivo, :pago_tarjeta, :numero_tarjeta,
				:tarjeta_habiente, :cambio, :estado, :idcliente, :idusuario)";

				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":tipo_pago",$tipo_pago);
				$stmt->bindParam(":tipo_comprobante",$tipo_comprobante);
				$stmt->bindParam(":sumas",$sumas);
				$stmt->bindParam(":iva",$iva);
				$stmt->bindParam(":exento",$exento);
				$stmt->bindParam(":retenido",$retenido);
				$stmt->bindParam(":descuento",$descuento);
				$stmt->bindParam(":total",$total);
				$stmt->bindParam(":sonletras",$sonletras);
				$stmt->bindParam(":pago_efectivo",$pago_efectivo);
				$stmt->bindParam(":pago_tarjeta",$pago_tarjeta);
				$stmt->bindParam(":numero_tarjeta",$numero_tarjeta);
				$stmt->bindParam(":tarjeta_habiente",$tarjeta_habiente);
				$stmt->bindParam(":cambio",$cambio);
				$stmt->bindParam(":estado",$estado);
				$stmt->bindParam(":idcliente",$idcliente);
				$stmt->bindParam(":idusuario",$idusuario);

				if($stmt->execute())
				{
					$count = $stmt->rowCount();
					if($count == 0){
						$data = "Duplicado";
 	   					echo json_encode($data);
					} else {
						$data = "Validado";
 	   					echo json_encode($data);
					}
				} else {

					$data = "Error_Insertar_Venta";
 	   		 	 	echo json_encode($data);
				}
				$dbconec = null;
			} catch (Exception $e) {
				$data = "Error_Insertar_Venta";
				echo json_encode($data);
				//echo $e;

			}

		}

		public static function Insertar_DetalleVenta($idproducto, $cantidad, $precio_unitario, $exento, $descuento, $fecha_vence, $importe){

			try {

				$query = "CALL sp_insert_detalleventa(:idproducto, :cantidad, :precio_unitario, :exento, :descuento, :fecha_vence, :importe)";

				$stmt = Conexion::Conectar()->prepare($query);
		   		$stmt->bindParam(":idproducto",$idproducto);
		   		$stmt->bindParam(":cantidad",$cantidad);
		   		$stmt->bindParam(":precio_unitario",$precio_unitario);
		   		$stmt->bindParam(":exento",$exento);
		   		$stmt->bindParam(":descuento",$descuento);
		   		$stmt->bindParam(":fecha_vence",$fecha_vence);
		   		$stmt->bindParam(":importe",$importe);

				$stmt->execute();

				$dbconec = null;

			} catch (Exception $e) {

				$data = "Error_Insertar_DetalleVenta";
 	   		echo json_encode($data);
				//echo $e;
			}

		}

		public static function Imprimir_Ticket_DetalleVenta($idventa)
		{
			$dbconec = Conexion::Conectar();

			try
			{
				$query = "CALL sp_detalle_imprimir_ticket_venta(:idventa);";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":idventa",$idventa);
				$stmt->execute();
				$count = $stmt->rowCount();

				if($count > 0)
				{
					return $stmt;
				}


				$dbconec = null;
			} catch (Exception $e) {

				echo '<span class="label label-danger label-block">ERROR AL CARGAR LOS DATOS, PRESIONE F5</span>';
			}
		}

		public static function Imprimir_Ticket_Cli($p_idcliente)
		{
			$dbconec = Conexion::Conectar();

			try
			{
				$query = "select * from cliente where idcliente=:idcliente";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":idcliente",$p_idcliente);
				$stmt->execute();
				$count = $stmt->rowCount();

				if($count > 0)
				{
					return $stmt->fetch();
				}


				$dbconec = null;
			} catch (Exception $e) {

				echo '<span class="label label-danger label-block">ERROR AL CARGAR LOS DATOS, PRESIONE F5</span>';
			}
		}

		public static function Imprimir_Ticket_Venta($idventa)
{
	$dbconec = Conexion::Conectar();
	try
	{
		$query = "CALL sp_imprimir_ticket(:idventa);";
		$stmt = $dbconec->prepare($query);
		$stmt->bindParam(":idventa",$idventa);
		$stmt->execute();
		$count = $stmt->rowCount();
		if($count > 0)
		{
			return $stmt->fetchAll();
		}
		$dbconec = null;
	} catch (Exception $e) {
		echo '<span class="label label-danger label-block">ERROR AL CARGAR LOS DATOS, PRESIONE F5</span>';
	}
}

public static function Ver_idproducto($idcotizacion)
		{
			$dbconec = Conexion::Conectar();

			try
			{
				$query = "CALL sp_view_idproducto(:idcotizacion);";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":idcotizacion",$idcotizacion);
				$stmt->execute();
				$count = $stmt->rowCount();

				if($count > 0)
				{
					return $stmt->fetchAll();
				}


				$dbconec = null;
			} catch (Exception $e) {

				echo '<span class="label label-danger label-block">ERROR AL CARGAR LOS DATOS, Ver_idproducto</span>';
			}
		}

	}
		



 ?>
