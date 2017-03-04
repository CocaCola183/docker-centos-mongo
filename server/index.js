const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const ObjectId = Schema.ObjectId;
const async = require('async');

// 配置schema
let user = new Schema({
	_id: {type: Number},
  name: {type: String, default: 'ivik'}
});

// 暴露model
mongoose.model('User', user);
const UserModel = mongoose.model('User');

// 这里的ip和端口号是集群启动的时候配置的
console.log('开始连接数据库...');
mongoose.connect('mongodb://192.168.99.100:9000,192.168.99.100:9001/test', 
{
	db: {
		// readPreference: 'secondary', // primary, primaryPreferred, secondary, secondaryPreferred, nearest
		// slaveOk: true
	},
	mongos: true
}, (err) => {
	console.log('连接成功');
	clear(dbTest);
});

function clear(callback) {
	UserModel.remove({}, function(err) {
		if (err) {
			console.log('clear data failed');
		} else {
			callback();
		}
	});
}

function dbTest() {
	console.log('开始增删改查测试程序');
	var count = 0;
	var timer = setInterval(function() {
		console.log('\n');
		async.series(
			[
				function(callback) {
					UserModel.create([{_id: count}, {_id: ++count}, {_id: ++count}], function(err, result) {
						if (err) {
							console.log('insert faild at', (count - 2), (count - 1), count);
							callback(err);
						} else {
							console.log('insert data success at', (count - 2), (count - 1), count);
							callback();
						}
					});
				},
				function(callback) {
					UserModel.update({_id: (count - 2)}, {$set: {name: 'kivi'}}, function(err, result) {
						if (err) {
							console.log('update faild at', (count - 2));
							callback(err);
						} else {
							console.log('update data success at', (count - 2));
							callback();
						}
					});
				},
				function(callback) {
					UserModel.findOne({_id: (count - 2)}, function(err, user) {
						if (err) {
							console.log('find faild at', count);
							callback(err);
						} else {
							console.log('find data success at ' + (count - 2), JSON.stringify(user));
							callback();
						}
					});
				},
				function(callback) {
					UserModel.remove({_id: count}, function(err, user) {
						if (err) {
							console.log('delete faild at', count);
							callback(err);
						} else {
							console.log('delete success at', count);
							callback();
						}
					});
				},
				function(callback) {

					async.parallel({
				    foo: function(innerCallback) {
				        UserModel.count({name: 'ivik'}, function(err, count) {
								if (err) {
									console.log('统计初始数据数量失败');
									innerCallback(err);
								} else {
									innerCallback(null, parseInt(count, 10));
								}
							});
				    },
				    bar: function(innerCallback) {
				       UserModel.count({name: 'kivi'}, function(err, count) {
								if (err) {
									console.log('统计修改数据数量失败');
									innerCallback(err);
								} else {
									innerCallback(null, parseInt(count, 10));
								}
							});
				    },
				    expected: function(innerCallback) {
							UserModel.findOne({}, null, {sort: {_id: -1}}, function(err, result) {
								if (err) {
									console.log('查询最后一条数据失败');
									innerCallback(err);
								} else {
									innerCallback(null, parseInt((result._id + 2) / 3, 10));
								}
							});
						}
					},
					function(err, result) {
						if (err) {
							callback(err);
						} else {
							if (result.foo == result.bar && result.bar == result.expected) {
								console.log('数据检查成功');
							} else {
								console.log('foo', result.foo);
								console.log('bar', result.bar);
								console.log('expected', result.expected);
								console.log('=============================数据丢失或错乱，程序终止=============================');
								clearInterval(timer);
								mongoose.disconnect();
							}
							callback();
						}
					});
				}
			], 
			function(err) {
				if (err) {
					console.log(err);
				}
				else {
					count++;
				}
			}
		);
	}, 3000);
}