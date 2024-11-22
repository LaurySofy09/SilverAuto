$(document).ready(function () {
    var dataString = 'flagConsulta=1';
    cargarDiv("#reload-div", "web/ajax/reload-factura.php", dataString);
});

function cargarDiv(div, url, dataString) {
    $(div).load(url);
    cargarDataFactura(dataString);
}

function cargarDataFactura(dataString) {
    console.log('Enviando datos:', dataString); // Verifica los datos enviados
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
                    row += '<td>' + factura.fecha_venta + '</td>';
                    row += '<td>' + factura.numero_venta + '</td>';
                    row += '<td>' + factura.nombre_cliente + '</td>';
                    row += '<td>' + factura.cantidad + '</td>';
                    row += '<td>' + factura.productos_y_precios + '</td>';
                    row += '<td>' + factura.sumas + '</td>';
                    row += '<td>' + factura.iva + '</td>';
                    row += '<td>' + factura.exento + '</td>';
                    row += '<td>' + factura.retenido + '</td>';
                    row += '<td>' + factura.descuento + '</td>';
                    row += '<td>' + factura.total + '</td>';
                    row += '<td>' + '<button type="button" onclick="AbrirModal(\'' + 
                        factura.idventa + '\', \'' + 
                        factura.fecha_venta + '\', \'' + 
                        factura.numero_venta + '\', \'' + 
                        factura.nombre_cliente + '\', \'' + 
                        factura.cantidad + '\', \'' + 
                        factura.productos_y_precios + '\', \'' + 
                        factura.sumas + '\', \'' + 
                        factura.iva + '\', \'' + 
                        factura.exento + '\', \'' + 
                        factura.retenido + '\', \'' + 
                        factura.descuento + '\', \'' + 
                        factura.total + '\');" class="btn bg-success-700 btn-sm btnVer" style="display: inline-block;"> Ver </button>' + '</td>';
                    // Añade más celdas según los campos de la factura
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

function AbrirModal(idventa, fecha_venta, numero_venta, nombre_cliente, cantidad, productos_y_precios, sumas, iva, exento, retenido, descuento, total){
    
    $("#hiddenIdv").val(idventa);
        //actualizar el contenido
    $('#modal_iconified_cash').find('.modal-body').html(`
        <p><b>Fecha Venta:</b> ${fecha_venta}</p>
        <p><b>Número Venta:</b> ${numero_venta}</p>
        <p><b>Nombre Cliente:</b> ${nombre_cliente}</p>
        <p><b>Cantidad:</b> ${cantidad}</p>
        <p><b>Productos y Precios:</b> ${productos_y_precios}</p>
        <p><b>Sumas:</b> ${sumas}</p>
        <p><b>ITBMS:</b> ${iva}</p>
        <p><b>Exento:</b> ${exento}</p>
        <p><b>Retenido:</b> ${retenido}</p>
        <p><b>Descuento:</b> ${descuento}</p>
        <p><b>Total:</b> ${total}</p>
    `);

    // Abre el modal
    $('#modal_iconified_cash').modal('show');

}


