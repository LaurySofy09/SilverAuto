<?php 
function format_uri( $string, $separator = '-' )
{
    $accents_regex = '~&([a-z]{1,2})(?:acute|cedil|circ|grave|lig|orn|ring|slash|th|tilde|uml);~i';
    $special_cases = array( '&' => 'and', "'" => '');
    $string = mb_strtolower( trim( $string ), 'UTF-8' );
    $string = str_replace( array_keys($special_cases), array_values( $special_cases), $string );
    $string = preg_replace( $accents_regex, '$1', htmlentities( $string, ENT_QUOTES, 'UTF-8' ) );
    $string = preg_replace("/[^a-z0-9]/u", "$separator", $string);
    $string = preg_replace("/[$separator]+/u", "$separator", $string);
    return $string;
}

if($_GET["op"]=="Registro"){
	
	if (!empty($_FILES["txtImagen"]["tmp_name"])) {
		
		$textura = $_FILES['txtImagen']['name']; 
		$iFileType = pathinfo($textura,PATHINFO_EXTENSION);
		$file_array2 = explode(".", $textura);
		$limpia=format_uri($file_array2[0]);
		$imagen = $limpia.'.'.$iFileType;
		$ruta = 'web/images_productos/'. $imagen;
		move_uploaded_file($_FILES['txtImagen']['tmp_name'], $ruta);
		//Borramos archivo anterior
		if(!empty($_POST["cimagen"])){
		  unlink('web/images_productos/'.$_POST["cimagen"]);
	     }
	}
}elseif($_GET["op"]=="Edicion"){
		if (!empty($_FILES["txtImagen"]["tmp_name"])) {
			$textura = $_FILES['txtImagen']['name']; 
			$iFileType = pathinfo($textura,PATHINFO_EXTENSION);
			$file_array2 = explode(".", $textura);
			$limpia=format_uri($file_array2[0]);
			$imagen = $limpia.'.'.$iFileType;
			$ruta = 'web/images_productos/'. $imagen;
			move_uploaded_file($_FILES['txtImagen']['tmp_name'], $ruta);
			//Borramos archivo anterior
			if(!empty($_POST["cimagen"])){
			  unlink('web/images_productos/'.$_POST["cimagen"]);
			 }
	   }
}


if($_GET["user"]=="Registro"){
	
	if (!empty($_FILES["txtImagen"]["tmp_name"])) {
		
		$textura = $_FILES['txtImagen']['name']; 
		$iFileType = pathinfo($textura,PATHINFO_EXTENSION);
		$file_array2 = explode(".", $textura);
		$limpia=format_uri($file_array2[0]);
		$imagen = $limpia.'.'.$iFileType;
		$ruta = 'web/images_user/'. $imagen;
		move_uploaded_file($_FILES['txtImagen']['tmp_name'], $ruta);
		//Borramos archivo anterior
		if(!empty($_POST["cimagen"])){
		  unlink('web/images_user/'.$_POST["cimagen"]);
	     }
	}
}elseif($_GET["user"]=="Edicion"){
		if (!empty($_FILES["txtImagen"]["tmp_name"])) {
			$textura = $_FILES['txtImagen']['name']; 
			$iFileType = pathinfo($textura,PATHINFO_EXTENSION);
			$file_array2 = explode(".", $textura);
			$limpia=format_uri($file_array2[0]);
			$imagen = $limpia.'.'.$iFileType;
			$ruta = 'web/images_user/'. $imagen;
			move_uploaded_file($_FILES['txtImagen']['tmp_name'], $ruta);
			//Borramos archivo anterior
			if(!empty($_POST["cimagen"])){
			  unlink('web/images_user/'.$_POST["cimagen"]);
			 }
	   }
}
?>