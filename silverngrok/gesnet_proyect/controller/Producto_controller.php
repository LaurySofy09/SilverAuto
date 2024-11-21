<?php

	class Producto {

		public static function Print_Barcode($idproducto){

			$filas = ProductoModel::Print_Barcode($idproducto);
			return $filas;

		}

		
    	public static function View_Productos() {
        return ProductoModel::View_Productos();
		    }
			
		public static function View_ProductosXid($idproducto) {
        return ProductoModel::View_ProductosXid($idproducto);
		}
		

		public static function Listar_Productos(){

			$filas = ProductoModel::Listar_Productos();
			return $filas;

		}

		public static function Listar_Historial(){

			$filas = ProductoModel::Listar_Historial();
			return $filas;

		}


		public static function Autocomplete_Producto($search){

			$filas = ProductoModel::Autocomplete_Producto($search);
			return $filas;

		}

		public static function Listar_Productos_Activos(){

			$filas = ProductoModel::Listar_Productos_Activos();
			return $filas;

		}

		public static function Listar_Productos_Inactivos(){

			$filas = ProductoModel::Listar_Productos_Inactivos();
			return $filas;

		}

		public static function Listar_Productos_Agotados(){

			$filas = ProductoModel::Listar_Productos_Agotados();
			return $filas;

		}

		public static function Listar_Productos_Vigentes(){

			$filas = ProductoModel::Listar_Productos_Vigentes();
			return $filas;

		}


		public static function Listar_Perecederos(){

			$filas = ProductoModel::Listar_Perecederos();
			return $filas;

		}

		public static function Listar_No_Perecederos(){

			$filas = ProductoModel::Listar_No_Perecederos();
			return $filas;

		}


		public static function Listar_Categorias(){

			$filas = ProductoModel::Listar_Categorias();
			return $filas;

		}

		public static function Listar_Dias(){

			$filas = ProductoModel::Listar_Dias();
			return $filas;

		}

		public static function Listar_Marcas(){

			$filas = ProductoModel::Listar_Marcas();
			return $filas;

		}

		public static function Listar_Presentaciones(){

			$filas = ProductoModel::Listar_Presentaciones();
			return $filas;

		}

		public static function Listar_Proveedores(){

			$filas = ProductoModel::Listar_Proveedores();
			return $filas;

		}

		public static function Insertar_Producto($codigo_barra, $codigo_alternativo, $nombre_producto, $precio_compra, $precio_venta, $precio_venta1, $precio_venta2, $precio_venta3, $precio_venta_mayoreo, $stock,$stock_min, $idcategoria, $idmarca, $idpresentacion, $exento, $inventariable, $perecedero, $imagen, $usuario){


			$cmd = ProductoModel::Insertar_Producto($codigo_barra, $codigo_alternativo, $nombre_producto, $precio_compra, $precio_venta, $precio_venta1, $precio_venta2, $precio_venta3, $precio_venta_mayoreo, $stock,$stock_min, $idcategoria, $idmarca, $idpresentacion, $exento, $inventariable, $perecedero,$imagen, $usuario);

		}

		public static function Editar_Producto($idproducto, $codigo_barra, $codigo_alternativo, $nombre_producto, $precio_compra, $precio_venta, $precio_venta1, $precio_venta2, $precio_venta3, $precio_venta_mayoreo, $stock_min, $idcategoria, $idmarca, $idpresentacion, $estado, $exento, $inventariable, $perecedero, $imagen,$cimagen,$usuario){

			$cmd = ProductoModel::Editar_Producto($idproducto, $codigo_barra, $codigo_alternativo, $nombre_producto, $precio_compra, $precio_venta, $precio_venta1, $precio_venta2, $precio_venta3, $precio_venta_mayoreo, $stock_min, $idcategoria,$idmarca, $idpresentacion, $estado, $exento, $inventariable, $perecedero, $imagen,$cimagen,$usuario);

		}

	}


?>