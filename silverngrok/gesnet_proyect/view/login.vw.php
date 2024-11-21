
	<script type="text/javascript" src="web/custom-js/login.js"></script>
		<!-- Form with validation -->
		<form autocomplete="off" action="" class="form-validate">
			<div class="panel panel-body login-form">
				<div class="text-center">
					<img width="175" height="100"  src="./web/assets/images/LOGO_silverf.png">
					<h5 class="content-group">Bienvenido a Silver Autopartes<small class="display-block">Iniciar Sesión</small></h5>
				</div>

				<div class="form-group has-feedback has-feedback-left">
					<input type="text" class="form-control" id="username" placeholder="Usuario" name="username" required="required">
					<div class="form-control-feedback">
						<i class="icon-user text-muted"></i>

					</div>
					<span id="error-user" class="label label-danger label-block"></span>
				</div>

				<div class="form-group has-feedback has-feedback-left">
					<input type="password" class="form-control" id="password" placeholder="Password" name="password" required="required">
					<div class="form-control-feedback">
						<i class="icon-lock2 text-muted"></i>
					</div>
				</div>

				<div class="form-group">
					<button type="submit" class="btn bg-blue btn-block">Ingresar al Sistema <i class="icon-lock5"></i></button>
				</div>
		</form>
		<!-- /form with validation -->
