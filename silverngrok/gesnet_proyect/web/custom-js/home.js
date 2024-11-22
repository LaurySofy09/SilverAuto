$(document).ready(function () {

cargarDataFacturaCredito('flagConsulta=2');

});


function cargarDataFacturaCredito(dataString) {
	
    $.ajax({
        type: 'POST',
        dataType: 'json',
        url: 'web/ajax/ajxfactura.php',
        data: dataString,
        success: function(response) {
            if (response.status === 'empty') {
                $('#resultado').html('No hay facturas.');
            } else if (response.status === 'error') {
                $('#resultado').html('Error al cargar las facturas: ' + response.message);
            } else {
                // Limpiar cualquier contenido previo
                $('#facturasTable tbody').empty();

                // Asumimos que response es un array de objetos
                response.forEach(function(factura) {
                    let row = '<tr>';
                    row += '<td>' + factura.idventa + '</td>';
                    row += '<td>' + factura.fecha_factura + '</td>';
                    row += '<td>' + factura.dias_transcurridos + '</td>';
                    row += '<td>' + factura.cantidad_dias + '</td>';
                    row += '<td>' + factura.numero_venta + '</td>';
                    row += '<td>' + factura.nombre_cliente + '</td>';
                    row += '<td>' + factura.productos_y_precios + '</td>';
                    row += '<td>' + factura.total + '</td>';
                    row += '</tr>';
                    $('#facturasTable tbody').append(row);
                });

               // Inicializa DataTable con la opción de orden descendente
                $('#facturasTable').DataTable({
                    "order": [[0, "desc"]] // Ordenar por la primera columna (idventa) en orden descendente
                });

            }
        },
        error: function(xhr, status, error) {
            $('#resultado').html('Error en la solicitud AJAX.');
            console.log('Error: ' + error + ' __xhr: ' + xhr + ' __status: ' + status);
        }
    });

}