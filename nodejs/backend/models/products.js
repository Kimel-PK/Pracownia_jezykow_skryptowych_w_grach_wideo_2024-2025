module.exports = (sequelize, DataTypes) => {
    
    const products = sequelize.define("products", {
        name: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        description: {
            type: DataTypes.TEXT('long'),
            allowNull: true,
        },
        imgUrl: {
			type: DataTypes.STRING,
			allowNull: true,
		},
        price: {
            type: DataTypes.DECIMAL(10,2),
            allowNull: false,
        },
        categoryId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'categories',
                key: 'id'
            }
        }
    },
    {
        tableName: 'products',
        timestamps: false
    })
    
    products.associate = (models) => {
        products.belongsTo(models.categories, {
            foreignKey: 'categoryId',
            as: 'category'
        });
    };
    
    return products
}