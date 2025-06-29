export const bookSchema = {
    type: 'object',
    properties: {
        _id: {type: 'string'},
        qrCodeId: {type: 'string'},
        title: {type: 'string'},
        authors: {type: 'array', items: {type: 'string'}},
        isbn: {type: 'string'},
        description: {type: 'string'},
        coverImage: {type: 'string'},
        publisher: {type: 'string'},
        categories: {type: 'array', items: {type: 'string'}},
        parutionYear: {type: 'number'},
        pages: {type: 'number'},
        takenHistory: {
            type: 'array',
            items: {
                type: 'object',
                properties: {
                    username: {type: 'string'},
                    timestamp: {type: 'string', format: 'date-time'}
                }
            }
        },
        givenHistory: {
            type: 'array',
            items: {
                type: 'object',
                properties: {
                    username: {type: 'string'},
                    timestamp: {type: 'string', format: 'date-time'}
                }
            }
        },
        dateLastAction: {type: 'string', format: 'date-time'}
    }
}

export const threadSchema = {
    type: 'object',
    properties: {
        _id: { type: 'string' },
        username: { type: 'string' },
        title: { type: 'string' },
        image: { type: 'string' },
        bookTitle: { type: 'string' },
        timestamp: { type: 'string', format: 'date-time' },
        messages: {
            type: 'array',
            items: {
                type: 'object',
                properties: {
                    _id: { type: 'string' },
                    username: { type: 'string' },
                    timestamp: { type: 'string', format: 'date-time' },
                    content: { type: 'string' },
                    respondsTo: { type: 'string' },
                    reactions: {
                        type: 'array',
                        items: {
                            type: 'object',
                            properties: {
                                _id: { type: 'string' },
                                username: { type: 'string' },
                                reactIcon: { type: 'string' },
                                timestamp: { type: 'string', format: 'date-time' }
                            }
                        }
                    }
                }
            }
        }
    }
}

export const userSchema = {
    type: 'object',
    properties: {
        _id: { type: 'string' },
        username: { type: 'string' },
        password: { type: 'string' },
        email: { type: 'string' },
        phone: { type: 'string' },
        notificationKeyWords: { type: 'array', items: { type: 'string' } },
        numSavedBooks: { type: 'number' },
        notifications: {
            type: 'array',
            items: {
                type: 'object',
                properties: {
                    timestamp: { type: 'string', format: 'date-time' },
                    title: { type: 'string' },
                    content: { type: 'string' },
                    read: { type: 'boolean' }
                }
            }
        },
        requestNotificationRadius: { type: 'number', default: 5 }, // Default radius in km
        bookHistory: {
            type: 'array',
            items: {
                type: 'object',
                properties: {
                    bookId: { type: 'string' },
                    timestamp: { type: 'string', format: 'date-time' },
                    given: { type: 'boolean' }
                }
            }
        },
        followedBookboxes: { type: 'array', items: { type: 'string' } }, // Array of bookbox IDs
        createdAt: { type: 'string', format: 'date-time' }
    }
};

export const clearCollectionSchema = {
    description: 'Clear collection',
    tags: ['users', 'books', 'thread'],
    headers: {
        type: 'object',
        required: ['authorization'],
        properties: {
            authorization: {type: 'string'} // JWT token
        }
    },
    response: {
        200: {
            description: 'Collection cleared',
            type: 'object',
            properties: {
                message: {type: 'string'}
            }
        },
        500: {
            description: 'Internal server error',
            type: 'object',
            properties: {
                error: {type: 'string'}
            }
        }
    }
}

class CustomError extends Error {
    public statusCode: number;
    constructor(message : string, statusCode : number   ) {
        super(message);
        this.statusCode = statusCode;
        Error.captureStackTrace(this, this.constructor);
    }
}

export function newErr(statusCode: number, message: string): CustomError {
    return new CustomError(message, statusCode);
}

async function createAdminUser(server: any): Promise<string> {
    try {
        await server.inject({
            method: 'POST',
            url: '/users/register',
            payload: {
                username: process.env.ADMIN_USERNAME,
                password: process.env.ADMIN_PASSWORD,
                email: process.env.ADMIN_EMAIL,
            },
        });
        const response = await server.inject({
            method: 'POST',
            url: '/users/login',
            payload: {
                identifier: process.env.ADMIN_USERNAME,
                password: process.env.ADMIN_PASSWORD,
            },
        });
        return response.json().token;
    } catch (err : unknown) {
        const errorMessage = err instanceof Error ? err.message : 'Unknown error';
        if (errorMessage.includes('already taken')) {
            console.log('Admin user already exists.');
        } else {
            throw err;
        }
        return '';
    }
}

export async function reinitDatabase(server: any): Promise<string> {
    const token = await createAdminUser(server);
    await server.inject({
        method: 'DELETE',
        url: '/users/clear',
        headers:
            {
                Authorization: `Bearer ${token}`,
            },
    });
    await server.inject({
        method: 'DELETE',
        url: '/books/clear',
        headers:
            {
                Authorization: `Bearer ${token}`,
            },
    });
    await server.inject({
        method: 'DELETE',
        url: '/threads/clear',
        headers:
            {
                Authorization: `Bearer ${token}`,
            },
    });
    console.log('Database reinitialized.');
    return token;
}
