<?php 

	spl_autoload_register(function($className){
		$model = "../../model/". $className ."_model.php";
		$controller = "../../controller/". $className ."_controller.php";
	
		require_once($model);
		require_once($controller);
	});

	 $funcion = new Producto();

	 $keyword = trim($_REQUEST['term']);

	 $funcion->Autocomplete_Producto($keyword);
	  

?>