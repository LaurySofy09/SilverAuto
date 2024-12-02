<?php

	require_once('Conexion.php');

	class TallerModel extends Conexion
	{

		public static function Ver_Max_Orden(){
			$dbconec = Conexion::Conectar();
			try {

				$query = "CALL sp_view_maxorden()";
				$stmt = $dbconec->prepare($query);
				$stmt->execute();
				$count = $stmt->rowCount();
				if($count > 0){

					$filas = $stmt->fetchAll();
					if (is_array($filas) || is_object($filas))
					{
						foreach ($filas as $row => $column)
						{
							$maximo = $column['max_orden'];
						}
						echo json_encode($maximo);
					}
				}



				//

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

		public static function Listar_Tecnicos()
		{
			$dbconec = Conexion::Conectar();

			try
			{
				$query = "CALL sp_view_tecnico_activo();";
				$stmt = $dbconec->prepare($query);
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

    public static function Listar_Ordenes($date,$date2)
    {
      $dbconec = Conexion::Conectar();

      try
      {
        $query = "CALL sp_view_ordentaller(:date,:date2);";
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

		public static function Reporte_Taller($id)
    {
      $dbconec = Conexion::Conectar();

      try
      {
        $query = "CALL sp_view_report_ordentaller(:id);";
        $stmt = $dbconec->prepare($query);
        $stmt->bindParam(":id",$id);
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


		public static function Insertar_Orden($idcliente,$aparato,$modelo,$idmarca,$serie,$idtecnico,$averia,
		$observaciones,$deposito_revision,$deposito_reparacion,$parcial_pagar, $Repuesto, $ManoObra, $HoraObra, $AnioAuto)
		{
			$dbconec = Conexion::Conectar();
			try
			{
				$query = "CALL sp_insert_ordentaller(:idcliente,:aparato,:modelo,:idmarca,:serie,:idtecnico,:averia,
				:observaciones,:deposito_revision,:deposito_reparacion,:parcial_pagar,:Repuesto,:ManoObra, :HoraObra, :AnioAuto)";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":idcliente",$idcliente);
				$stmt->bindParam(":aparato",$aparato);
				$stmt->bindParam(":modelo",$modelo);
				$stmt->bindParam(":idmarca",$idmarca);
				$stmt->bindParam(":serie",$serie);
				$stmt->bindParam(":idtecnico",$idtecnico);
				$stmt->bindParam(":averia",$averia);
				$stmt->bindParam(":observaciones",$observaciones);
				$stmt->bindParam(":deposito_revision",$deposito_revision);
				$stmt->bindParam(":deposito_reparacion",$deposito_reparacion);
				$stmt->bindParam(":parcial_pagar",$parcial_pagar);
                $stmt->bindParam(":Repuesto",$Repuesto);
                $stmt->bindParam(":ManoObra",$ManoObra);
                $stmt->bindParam(":HoraObra",$HoraObra);
                $stmt->bindParam(":AnioAuto",$AnioAuto);
                //$stmt->bindParam(":Cedula",$Cedula);

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

					$data = "Error";
						echo json_encode($data);
				}
				$dbconec = null;
			} catch (Exception $e) {
				//$data = "Error";
				//echo json_encode($data);
				echo $e;
			}

		}
		
		public static function ConsultarDetalle_OrdenTaller($p_idorden)
		{
			$dbconec = Conexion::Conectar();
			try {
				$query = "CALL sp_consultar_detallesorden(:p_idorden);";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":p_idorden", $p_idorden);
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
		
		public static function EliminarDetalleOrden($p_iddetalle, $p_idproducto, $p_cantidad)
		{
			$dbconec = Conexion::Conectar();
			try {
				$query = "CALL SP_EliminsrDetalleOrden(:p_iddetalle, :p_idproducto, :p_cantidad);";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":p_iddetalle", $p_iddetalle);
				$stmt->bindParam(":p_idproducto", $p_idproducto);
				$stmt->bindParam(":p_cantidad", $p_cantidad);
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
		
		
		public static function InsertDetalleOrdenTaller($cartItems)
		{
			$dbconec = Conexion::Conectar();
			try {								
				foreach ($cartItems as $item) {
				$p_idproducto = $item['id'];
				$p_precio = $item['price'];
				$p_cantidad = $item['quantity'];
				$p_idorden  = $item['idOrden'];				
				$query = "CALL sp_insert_detalle_ordentaller(:p_idorden, :p_idproducto, :p_precio, :p_cantidad);";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":p_idorden", $p_idorden);
				$stmt->bindParam(":p_idproducto", $p_idproducto);
				$stmt->bindParam(":p_precio", $p_precio);
				$stmt->bindParam(":p_cantidad", $p_cantidad);
				$stmt->execute();
				}
				
				$count = $stmt->rowCount();
				if ($count > 0) {
					$result = $stmt->fetchAll(PDO::FETCH_ASSOC);
					return json_encode($result);
				} else {
					$dbconec->rollBack();
					return json_encode(['status' => 'empty']);
				}
				
			} catch (PDOException $e) {
				$dbconec->rollBack();
				error_log("Error PDO: " . $e->getMessage());
				return json_encode(['status' => 'error', 'message' => 'ERROR AL CARGAR LOS DATOS, PRESIONE F5']);
			} catch (Exception $e) {
				$dbconec->rollBack();
				error_log("Error general: " . $e->getMessage());
				return json_encode(['status' => 'error', 'message' => 'ERROR AL CARGAR LOS DATOS, PRESIONE F5']);
			}
			
		}

		public static function Insertar_Diagnostico($idorden,$diagnostico,$estado_aparato,$repuestos,$mano_obra,$fecha_alta,$fecha_retiro,
		$ubicacion,$parcial_pagar, $HoraObra)
		{
			$dbconec = Conexion::Conectar();
			try
			{
				$query = "CALL sp_insert_diagnostico(:idorden,:diagnostico,:estado_aparato,:repuestos,:mano_obra,:fecha_alta,:fecha_retiro,
				:ubicacion,:parcial_pagar, :HoraObra)";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":idorden",$idorden);
				$stmt->bindParam(":diagnostico",$diagnostico);
				$stmt->bindParam(":estado_aparato",$estado_aparato);
				$stmt->bindParam(":repuestos",$repuestos);
				$stmt->bindParam(":mano_obra",$mano_obra);
				$stmt->bindParam(":fecha_alta",$fecha_alta);
				$stmt->bindParam(":fecha_retiro",$fecha_retiro);
				$stmt->bindParam(":ubicacion",$ubicacion);
				$stmt->bindParam(":parcial_pagar",$parcial_pagar);
				$stmt->bindParam(":HoraObra",$HoraObra);
				

				if($stmt->execute())
				{

				  $data = "Validado";
   				  echo json_encode($data);

				} else {

					$data = "Error";
 	   		 	 	echo json_encode($data);
				}
				$dbconec = null;
			} catch (Exception $e) {
				//$data = "Error";
				//echo json_encode($data);
				echo $e;
			}

		}

		public static function Editar_Orden($idorden,$numero_orden,$idcliente,$aparato,$modelo,$idmarca,$Placa,$idtecnico,$averia,
		$observaciones,$deposito_revision,$deposito_reparacion, $montoRepuesto, $ManoObra, $horaObra, $AnioAuto)
		{
			$dbconec = Conexion::Conectar();
			try
			{
				$querys = "UPDATE ordentaller
SET numero_orden = :numero_orden, idcliente = :idcliente, aparato = :aparato,
modelo = :modelo, idmarca = :idmarca, Placa = :Placa, idtecnico = :idtecnico,
averia = :averia, observaciones = :observaciones, deposito_revision = :deposito_revision, deposito_reparacion = :deposito_reparacion, montoRepuesto = :montoRepuesto, ManoObra = :ManoObra, horaObra = :horaObra, AnioAuto = :AnioAuto
WHERE idorden = :idorden";
				$stmt = $dbconec->prepare($querys);
				
				$stmt->bindParam(":numero_orden",$numero_orden);
				//$stmt->bindParam(":fecha_ingreso",$fecha_ingreso);
				$stmt->bindParam(":idcliente",$idcliente);
				$stmt->bindParam(":aparato",$aparato);
				$stmt->bindParam(":modelo",$modelo);
				$stmt->bindParam(":idmarca",$idmarca);
				$stmt->bindParam(":Placa",$Placa);
				$stmt->bindParam(":idtecnico",$idtecnico);
				$stmt->bindParam(":averia",$averia);
				$stmt->bindParam(":observaciones",$observaciones);
				$stmt->bindParam(":deposito_revision",$deposito_revision);
				$stmt->bindParam(":deposito_reparacion",$deposito_reparacion);
                $stmt->bindParam(":montoRepuesto",$montoRepuesto);
                $stmt->bindParam(":ManoObra",$ManoObra);
                $stmt->bindParam(":horaObra",$horaObra);
                $stmt->bindParam(":AnioAuto",$AnioAuto);
				$stmt->bindParam(":idorden",$idorden);
                

				if($stmt->execute())
				{
				  $data = "Validado";
   				 echo json_encode($data);

				} else {

					$data = "Error";
 	   		 	 echo json_encode($data);
				}
				$dbconec = null;
			} catch (Exception $e) {
				//$data = "Error";
				//echo json_encode($data);
				echo $e;
			}

		}


		public static function Borrar_Orden($idtaller)
		{
			$dbconec = Conexion::Conectar();
			$response = array();
			try
			{
				$query = "CALL sp_delete_ordentaller(:idtaller)";
				$stmt = $dbconec->prepare($query);
				$stmt->bindParam(":idtaller",$idtaller);

				if($stmt->execute())
				{
					$response['status']  = 'success';
					$response['message'] = 'Orden Eliminada Correctamente!';
				} else {

					$response['status']  = 'error';
					$response['message'] = 'No pudimos eliminar la Orden!';
				}
				echo json_encode($response);
				$dbconec = null;
			} catch (Exception $e) {
				$response['status']  = 'error';
				$response['message'] = 'Error de Ejecucion';
				echo json_encode($response);

			}

		}

		public static function Count_Ordenes($date,$date2)
		{
			$dbconec = Conexion::Conectar();

			try
			{
				$query = "CALL sp_count_ordenes(:date,:date2);";
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


	}


 ?>
