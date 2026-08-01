// sample-function.ts
// explain-code.ps1 테스트용 샘플 TypeScript 함수

interface User {
  id: number;
  name: string;
  email: string;
  createdAt: Date;
  roles: string[];
}

interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
  hasNext: boolean;
}

async function fetchActiveUsers(
  page: number = 1,
  pageSize: number = 20,
  roleFilter?: string
): Promise<PaginatedResult<User>> {
  const offset = (page - 1) * pageSize;

  const query = `
    SELECT u.*, COUNT(*) OVER() as total_count
    FROM users u
    WHERE u.deleted_at IS NULL
      AND u.is_active = true
      ${roleFilter ? "AND ? = ANY(u.roles)" : ""}
    ORDER BY u.created_at DESC
    LIMIT ? OFFSET ?
  `;

  const params = roleFilter
    ? [roleFilter, pageSize, offset]
    : [pageSize, offset];

  const rows = await db.query(query, params);

  const total = rows[0]?.total_count ?? 0;
  const data: User[] = rows.map((row: any) => ({
    id: row.id,
    name: row.name,
    email: row.email,
    createdAt: new Date(row.created_at),
    roles: row.roles,
  }));

  return {
    data,
    total,
    page,
    pageSize,
    hasNext: offset + data.length < total,
  };
}
