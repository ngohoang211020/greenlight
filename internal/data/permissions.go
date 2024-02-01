package data

import (
	"context"
	"database/sql"
	"github.com/lib/pq"
	"time"
)

const (
	MovieRead  = "movies:read"
	MovieWrite = "movies:write"
)

type PermissionModel struct {
	DB *sql.DB
}

type Permissions []string

func (p Permissions) Include(code string) bool {
	for i := range p {
		if code == p[i] {
			return true
		}
	}
	return false
}

func (m PermissionModel) AddForUser(userID int64, codes ...string) error {
	query := `
	INSERT INTO users_permissions
	SELECT $1, permissions.id FROM permissions WHERE permissions.code = ANY ($2)`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err := m.DB.ExecContext(ctx, query, userID, pq.Array(codes))
	return err
}

func (m PermissionModel) GetAllForUser(userID int64) (Permissions, error) {
	query := `
	SELECT permissions.code FROM
	permissions 
	INNER JOIN users_permissions ON users_permissions.permission_id = permissions.id
	INNER JOIN users ON users.id= users_permissions.user_id 
	WHERE users.id = $1`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var permissions Permissions
	for rows.Next() {
		var permission string
		err := rows.Scan(&permission)
		if err != nil {
			return nil, err
		}
		permissions = append(permissions, permission)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return permissions, nil
}
