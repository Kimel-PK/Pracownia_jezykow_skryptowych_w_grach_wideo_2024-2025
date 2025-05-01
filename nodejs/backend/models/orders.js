module.exports = (sequelize, DataTypes) => {
    
    const orders = sequelize.define("orders", {
        name: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        address: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        phoneNumber: {
            type: DataTypes.STRING,
            allowNull: true,
        },
        productsList: {
			type: DataTypes.STRING,
			allowNull: true,
		},
    },
    {
        tableName: 'orders',
        timestamps: false
    })
    
    return orders
}