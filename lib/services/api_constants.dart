// api_constants.dart

// ✔️ SIN /api al final — evita duplicación
const String kBaseUrl = 'http://10.0.0.20:8000';

// 2. URLs de Autenticación (SimpleJWT)
const String kLoginUrl = '$kBaseUrl/api/auth/token/';
const String kRefreshTokenUrl = '$kBaseUrl/api/auth/token/refresh/';

const String kProfileUrl = '$kBaseUrl/api/auth/profile/';
const String kRegisterPacienteUrl = '$kBaseUrl/api/auth/register/paciente/';
const String kRegisterMedicoUrl = '$kBaseUrl/api/auth/register/medico/';
