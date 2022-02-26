# Beans Server Utils
#### A utilities and moderation addon for a dedicated Garry's Mod server

(Under active development)

# Documentation

## Defines
All defined vars can be found in [lua/bsu/defines.lua](https://github.com/Bonyoze/BSU/blob/main/lua/bsu/defines.lua)

## SQL Tables

| Realm  | Name                                                                                                | Description                                  |
|--------|-----------------------------------------------------------------------------------------------------|----------------------------------------------|
| SERVER | [SQL_GROUPS](https://github.com/Bonyoze/BSU/blob/main/lua/bsu/base/server/sql.lua#L3-L22)           | Stores group data                            |
| SERVER | [SQL_PLAYERS](https://github.com/Bonyoze/BSU/blob/main/lua/bsu/base/server/sql.lua#L24-L43)         | Stores important player data                 |
| SERVER | [SQL_BANS](https://github.com/Bonyoze/BSU/blob/main/lua/bsu/base/server/sql.lua#L45-L71)            | Stores and logs data for player bans/kicks   |
| SERVER | [SQL_GROUP_PRIVS](https://github.com/Bonyoze/BSU/blob/main/lua/bsu/base/server/sql.lua#L73-L89)     | Stores privilege data for groups             |
| SERVER | [SQL_PLAYER_PRIVS](https://github.com/Bonyoze/BSU/blob/main/lua/bsu/base/server/sql.lua#L91-L107)   | Stores privilege data for individual players |
| SERVER | [SQL_GROUP_LIMITS](https://github.com/Bonyoze/BSU/blob/main/lua/bsu/base/server/sql.lua#L109-L124)  | Stores limits data for groups                |
| SERVER | [SQL_PLAYER_LIMITS](https://github.com/Bonyoze/BSU/blob/main/lua/bsu/base/server/sql.lua#L109-L124) | Stores limits data for individual players    |
| SERVER | SQL_PDATA                                                                                           | Stores misc player data<br>**(currently not implemented)** |
| CLIENT | [SQL_PP](https://github.com/Bonyoze/BSU/blob/main/lua/bsu/base/client/sql.lua#L3-L15)               | Stores prop protection settings              |

### Privileges

| Name       | Description                                                           |
|------------|-----------------------------------------------------------------------|
| PRIV_MODEL | Used for restricting spawning certain models                          |
| PRIV_NPC   | Used for restricting spawning certain npcs                            |
| PRIV_SENT  | Used for restricting spawning certain scripted entities               |
| PRIV_SWEP  | Used for restricting spawning and picking up certain scripted weapons |
| PRIV_TOOL  | Used for restricting using certain tools                              |

### Prop Protection Grants

| Name             | Description                                      |
|------------------|--------------------------------------------------|
| PP_PHYSGUN   | Grant ability to use the physics gun on owned props  |
| PP_GRAVGUN   | Grant ability to use the gravity gun on owned props  |
| PP_TOOLGUN   | Grant ability to use the tool gun on owned props     |
| PP_USE       | Grant ability to pick up (with E) or use owned props |
| PP_DAMAGE    | Grant ability to damage self or owned props          |
| ~~PP_NOCOLLIDE~~ | Grant ability to collide with self or owned props<br>**(currently disabled due to high chance to cause issues; most likely will be removed)** |
