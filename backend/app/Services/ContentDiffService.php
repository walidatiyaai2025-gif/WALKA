<?php

namespace App\Services;

final class ContentDiffService
{
    /**
     * @param  array<string|int, mixed>|null  $before
     * @param  array<string|int, mixed>  $after
     * @return list<array{path:string,state:string,before:mixed,after:mixed}>
     */
    public function diff(?array $before, array $after): array
    {
        $rows = [];
        $this->walk($before ?? [], $after, '', $rows);

        usort($rows, static fn (array $left, array $right): int => strcmp($left['path'], $right['path']));

        return $rows;
    }

    /**
     * @param  array<string|int, mixed>  $before
     * @param  array<string|int, mixed>  $after
     * @param  list<array{path:string,state:string,before:mixed,after:mixed}>  $rows
     */
    private function walk(array $before, array $after, string $prefix, array &$rows): void
    {
        $keys = array_values(array_unique(array_merge(array_keys($before), array_keys($after))));
        usort($keys, static fn (string|int $a, string|int $b): int => strcmp((string) $a, (string) $b));

        foreach ($keys as $key) {
            if ($this->isSensitive((string) $key)) {
                continue;
            }

            $path = $this->path($prefix, $key);
            $hasBefore = array_key_exists($key, $before);
            $hasAfter = array_key_exists($key, $after);

            if ($hasBefore === false) {
                $rows[] = ['path' => $path, 'state' => 'added', 'before' => null, 'after' => $this->safeValue($after[$key])];

                continue;
            }
            if ($hasAfter === false) {
                $rows[] = ['path' => $path, 'state' => 'removed', 'before' => $this->safeValue($before[$key]), 'after' => null];

                continue;
            }

            $left = $before[$key];
            $right = $after[$key];
            if (is_array($left) && is_array($right)) {
                $this->walk($left, $right, $path, $rows);

                continue;
            }
            if ($left !== $right) {
                $rows[] = [
                    'path' => $path,
                    'state' => 'changed',
                    'before' => $this->safeValue($left),
                    'after' => $this->safeValue($right),
                ];
            }
        }
    }

    private function isSensitive(string $key): bool
    {
        return preg_match('/(?:password|secret|token|api[_-]?key|actor[_-]?fingerprint|storage[_-]?(?:path|disk)|source[_-]?path)/i', $key) === 1;
    }

    private function path(string $prefix, string|int $key): string
    {
        if (is_int($key) || ctype_digit((string) $key)) {
            return $prefix === '' ? '['.$key.']' : $prefix.'['.$key.']';
        }

        return $prefix === '' ? (string) $key : $prefix.'.'.$key;
    }

    private function safeValue(mixed $value): mixed
    {
        if (is_array($value) === false) {
            return $value;
        }

        $result = [];
        foreach ($value as $key => $item) {
            if ($this->isSensitive((string) $key)) {
                continue;
            }
            $result[$key] = $this->safeValue($item);
        }

        return $result;
    }
}
