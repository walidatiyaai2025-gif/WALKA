<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

final class RequireCatalogAdminToken
{
    public function handle(Request $request, Closure $next): Response
    {
        $expected = trim((string) config('walka.admin_token', ''));

        if (strlen($expected) < 32) {
            return $this->error(
                code: 'admin_auth_unconfigured',
                message: 'Catalog administration is disabled until a strong WALKA_ADMIN_TOKEN is configured.',
                status: 503,
            );
        }

        $provided = $request->bearerToken();
        if (! is_string($provided) || $provided === '' || ! hash_equals($expected, $provided)) {
            return $this->error(
                code: 'admin_unauthorized',
                message: 'A valid catalog administrator Bearer token is required.',
                status: 401,
                authenticate: true,
            );
        }

        $request->attributes->set('walka_admin_fingerprint', hash('sha256', $provided));

        $response = $next($request);
        $response->headers->set('Cache-Control', 'no-store');

        return $response;
    }

    private function error(string $code, string $message, int $status, bool $authenticate = false): JsonResponse
    {
        $response = response()->json([
            'error' => [
                'code' => $code,
                'message' => $message,
            ],
        ], $status);

        $response->headers->set('Cache-Control', 'no-store');
        if ($authenticate) {
            $response->headers->set('WWW-Authenticate', 'Bearer');
        }

        return $response;
    }
}
