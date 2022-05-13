
/*
 * Editor client script for DB table Person
 * Created by http://editor.datatables.net/generator
 */

(function($){

$(document).ready(function() {
	$.fn.dataTable.moment( 'DD-MM-YY' );

	var genderEditor = new $.fn.dataTable.Editor( {
		ajax: 'php/table.Gender.php',
		fields: [
			{
				"label": "Gender:",
				"name": "sex",
				//type: "datatable"
			}
		]
	} );

	var editor = new $.fn.dataTable.Editor( {
		ajax: 'php/table.Person.php',
		table: '#Person',
		fields: [
			{
				"label": "Name:",
				"name": "Person.name"
			},
			{
				"label": "DoB:",
				"name": "Person.dob",
				"type": "datetime",
				"format": "DD-MM-YY"
			},
			{
				"label": "Gender:",
				"name": "Person.gender",
				//type: "select"
				"type": "datatable",
				editor: genderEditor,

				optionsPair: {
				    value: 'id',
				},
				
				config: {
					ajax: 'php/table.Gender.php',
				    buttons: [
					{ extend: 'create', editor: genderEditor },
					{ extend: 'edit',   editor: genderEditor },
					{ extend: 'remove', editor: genderEditor }
				    ],
				    columns: [
					{
					    title: 'Gender',
					    data: 'sex'
					}
				    ]
				}

			}
		]
	} );

	var table = $('#Person').DataTable( {
		dom: 'Bfrtip',
		ajax: {
			url: 'php/table.Person.php',
			type: 'POST'
		},
		columns: [
			{
				"data": "Person.name"
			},
			{
				"data": "Person.dob"
			},
			{
				"data": "Gender.sex"
			}
		],
		select: true,
		lengthChange: false,
		buttons: [
			{ extend: 'create', editor: editor },
			{ extend: 'edit',   editor: editor },
			{ extend: 'remove', editor: editor }
		]
	} );
} );

}(jQuery));

