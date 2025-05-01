module.exports = (sequelize, DataTypes) => {
    
    const categories = sequelize.define("categories", {
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
    },
    {
        tableName: 'categories',
        timestamps: false
    })
    
    categories.associate = (models) => {
        categories.hasMany(models.products, {
            foreignKey: 'categoryId',
            as: 'products'
        });
    };    
    
    return categories
}