library IEEE;
use IEEE.STD_LOGIC_1164.all;

--Package for a ROM with data for a paddle slope of 20 degrees

package rom_package is

   type t_rom is array (0 to 511) of std_logic_vector (8 downto 0);

   constant C_ROM : t_rom := ("000000111",      --address 0
                              "000000011",      --address 1
                              "000000010",      --address 2
                              "000100001",      --address 3
                              "000100001",      --address 4
                              "000000001",      --address 5
                              "000000001",      --address 6
                              "000000001",      --address 7
                              "000000001",      --address 8
                              "000000001",      --address 9
                              "000000001",      --address 10
                              "000000001",      --address 11
                              "000000001",      --address 12
                              "000000001",      --address 13
                              "000000001",      --address 14
                              "000000001",      --address 15
                              "000100000",      --address 16
                              "000100000",      --address 17
                              "000100000",      --address 18
                              "000100000",      --address 19
                              "000100000",      --address 20
                              "000100000",      --address 21
                              "000100000",      --address 22
                              "000100000",      --address 23
                              "000100000",      --address 24
                              "000100000",      --address 25
                              "000100000",      --address 26
                              "000100000",      --address 27
                              "000100000",      --address 28
                              "000100000",      --address 29
                              "000100000",      --address 30
                              "000100000",      --address 31
                              "000000001",      --address 32
                              "000001111",      --address 33
                              "000101110",      --address 34
                              "000000111",      --address 35
                              "000000101",      --address 36
                              "001000100",      --address 37
                              "000100100",      --address 38
                              "001000011",      --address 39
                              "001000011",      --address 40
                              "001000011",      --address 41
                              "000100011",      --address 42
                              "000100011",      --address 43
                              "000100011",      --address 44
                              "000100011",      --address 45
                              "000100011",      --address 46
                              "000100011",      --address 47
                              "000100000",      --address 48
                              "001100001",      --address 49
                              "001100001",      --address 50
                              "001100001",      --address 51
                              "001100001",      --address 52
                              "001100001",      --address 53
                              "001100001",      --address 54
                              "001100001",      --address 55
                              "001100001",      --address 56
                              "001000010",      --address 57
                              "001000010",      --address 58
                              "001000010",      --address 59
                              "000100010",      --address 60
                              "000100010",      --address 61
                              "000100010",      --address 62
                              "000100010",      --address 63
                              "000100001",      --address 64
                              "000100101",      --address 65
                              "000101111",      --address 66
                              "000101111",      --address 67
                              "001001111",      --address 68
                              "000101011",      --address 69
                              "000101001",      --address 70
                              "001000111",      --address 71
                              "001000111",      --address 72
                              "001100110",      --address 73
                              "001000110",      --address 74
                              "001000110",      --address 75
                              "001100101",      --address 76
                              "001100101",      --address 77
                              "001100101",      --address 78
                              "001100101",      --address 79
                              "001000000",      --address 80
                              "001100001",      --address 81
                              "011000001",      --address 82
                              "011000010",      --address 83
                              "011000010",      --address 84
                              "010100010",      --address 85
                              "011000010",      --address 86
                              "010100010",      --address 87
                              "010100010",      --address 88
                              "010100010",      --address 89
                              "010000011",      --address 90
                              "001100011",      --address 91
                              "001100011",      --address 92
                              "001100011",      --address 93
                              "001100011",      --address 94
                              "001100011",      --address 95
                              "000100001",      --address 96
                              "000000011",      --address 97
                              "001001010",      --address 98
                              "000101111",      --address 99
                              "001001111",      --address 100
                              "001101111",      --address 101
                              "001001111",      --address 102
                              "001101110",      --address 103
                              "001101100",      --address 104
                              "001001011",      --address 105
                              "001101010",      --address 106
                              "010001001",      --address 107
                              "001101001",      --address 108
                              "010001000",      --address 109
                              "010001000",      --address 110
                              "001101000",      --address 111
                              "001000000",      --address 112
                              "010000001",      --address 113
                              "011000010",      --address 114
                              "100000010",      --address 115
                              "100100010",      --address 116
                              "100000011",      --address 117
                              "100100011",      --address 118
                              "011100011",      --address 119
                              "100000011",      --address 120
                              "011100011",      --address 121
                              "011100011",      --address 122
                              "011100011",      --address 123
                              "011000100",      --address 124
                              "010100100",      --address 125
                              "010100100",      --address 126
                              "010100100",      --address 127
                              "000100001",      --address 128
                              "001000011",      --address 129
                              "001000111",      --address 130
                              "001101111",      --address 131
                              "001101111",      --address 132
                              "001001111",      --address 133
                              "010001111",      --address 134
                              "010001111",      --address 135
                              "010001111",      --address 136
                              "010001111",      --address 137
                              "001101111",      --address 138
                              "010001110",      --address 139
                              "010001101",      --address 140
                              "010001101",      --address 141
                              "010001100",      --address 142
                              "010101011",      --address 143
                              "001000000",      --address 144
                              "010000001",      --address 145
                              "011000010",      --address 146
                              "100100010",      --address 147
                              "100100011",      --address 148
                              "101100011",      --address 149
                              "101100011",      --address 150
                              "101100100",      --address 151
                              "101100100",      --address 152
                              "101000100",      --address 153
                              "101000100",      --address 154
                              "101000100",      --address 155
                              "100100100",      --address 156
                              "100100100",      --address 157
                              "100000101",      --address 158
                              "011100101",      --address 159
                              "000100001",      --address 160
                              "001000011",      --address 161
                              "001000110",      --address 162
                              "001101011",      --address 163
                              "001101111",      --address 164
                              "010001111",      --address 165
                              "001101111",      --address 166
                              "001101111",      --address 167
                              "010101111",      --address 168
                              "010001111",      --address 169
                              "010001111",      --address 170
                              "010101111",      --address 171
                              "010001111",      --address 172
                              "010101111",      --address 173
                              "010001111",      --address 174
                              "010001111",      --address 175
                              "001000000",      --address 176
                              "010100001",      --address 177
                              "011000010",      --address 178
                              "100000011",      --address 179
                              "101100011",      --address 180
                              "101100100",      --address 181
                              "110000100",      --address 182
                              "111000100",      --address 183
                              "111000100",      --address 184
                              "111100100",      --address 185
                              "110100101",      --address 186
                              "110000101",      --address 187
                              "110000101",      --address 188
                              "110000101",      --address 189
                              "101100101",      --address 190
                              "101100101",      --address 191
                              "000000000",      --address 192
                              "000100010",      --address 193
                              "001000101",      --address 194
                              "001001001",      --address 195
                              "001101111",      --address 196
                              "010001111",      --address 197
                              "010001111",      --address 198
                              "010101111",      --address 199
                              "010101111",      --address 200
                              "010001111",      --address 201
                              "010101111",      --address 202
                              "010101111",      --address 203
                              "011001111",      --address 204
                              "010101111",      --address 205
                              "010101111",      --address 206
                              "010101111",      --address 207
                              "001000000",      --address 208
                              "010100001",      --address 209
                              "011100010",      --address 210
                              "100100011",      --address 211
                              "101100011",      --address 212
                              "110000100",      --address 213
                              "111000100",      --address 214
                              "111000101",      --address 215
                              "111100101",      --address 216
                              "111100101",      --address 217
                              "111100101",      --address 218
                              "111100101",      --address 219
                              "111100110",      --address 220
                              "111000110",      --address 221
                              "111000110",      --address 222
                              "111000110",      --address 223
                              "000000000",      --address 224
                              "000100010",      --address 225
                              "001100101",      --address 226
                              "001101000",      --address 227
                              "010001101",      --address 228
                              "001101111",      --address 229
                              "010001111",      --address 230
                              "010101111",      --address 231
                              "010101111",      --address 232
                              "011001111",      --address 233
                              "011001111",      --address 234
                              "010101111",      --address 235
                              "010101111",      --address 236
                              "011101111",      --address 237
                              "011101111",      --address 238
                              "011001111",      --address 239
                              "001000000",      --address 240
                              "010100001",      --address 241
                              "011100010",      --address 242
                              "100100011",      --address 243
                              "101100100",      --address 244
                              "111000100",      --address 245
                              "111000101",      --address 246
                              "111100101",      --address 247
                              "111100101",      --address 248
                              "111100110",      --address 249
                              "111100110",      --address 250
                              "111100110",      --address 251
                              "111100110",      --address 252
                              "111100110",      --address 253
                              "111100111",      --address 254
                              "111100111",      --address 255
                              "000000000",      --address 256
                              "000100010",      --address 257
                              "001000100",      --address 258
                              "001100111",      --address 259
                              "001101011",      --address 260
                              "010101111",      --address 261
                              "010001111",      --address 262
                              "010101111",      --address 263
                              "010101111",      --address 264
                              "011001111",      --address 265
                              "010101111",      --address 266
                              "011001111",      --address 267
                              "011101111",      --address 268
                              "011001111",      --address 269
                              "011101111",      --address 270
                              "011101111",      --address 271
                              "001000000",      --address 272
                              "010100001",      --address 273
                              "100000010",      --address 274
                              "100100011",      --address 275
                              "101100100",      --address 276
                              "111000100",      --address 277
                              "111100101",      --address 278
                              "111100101",      --address 279
                              "111100110",      --address 280
                              "111100110",      --address 281
                              "111100110",      --address 282
                              "111100111",      --address 283
                              "111100111",      --address 284
                              "111100111",      --address 285
                              "111100111",      --address 286
                              "111100111",      --address 287
                              "000000000",      --address 288
                              "000100010",      --address 289
                              "001000100",      --address 290
                              "010000111",      --address 291
                              "001101010",      --address 292
                              "010101111",      --address 293
                              "010001111",      --address 294
                              "011001111",      --address 295
                              "011001111",      --address 296
                              "011001111",      --address 297
                              "011101111",      --address 298
                              "011001111",      --address 299
                              "011001111",      --address 300
                              "011101111",      --address 301
                              "011101111",      --address 302
                              "011101111",      --address 303
                              "001000000",      --address 304
                              "010100001",      --address 305
                              "100000010",      --address 306
                              "100100011",      --address 307
                              "110000100",      --address 308
                              "111100100",      --address 309
                              "111100101",      --address 310
                              "111100110",      --address 311
                              "111100110",      --address 312
                              "111100111",      --address 313
                              "111100111",      --address 314
                              "111100111",      --address 315
                              "111100111",      --address 316
                              "111101000",      --address 317
                              "111101000",      --address 318
                              "111101000",      --address 319
                              "000000000",      --address 320
                              "000100010",      --address 321
                              "001000100",      --address 322
                              "010000111",      --address 323
                              "010101010",      --address 324
                              "010001101",      --address 325
                              "011001111",      --address 326
                              "011001111",      --address 327
                              "011001111",      --address 328
                              "011001111",      --address 329
                              "011001111",      --address 330
                              "011101111",      --address 331
                              "100001111",      --address 332
                              "011101111",      --address 333
                              "011101111",      --address 334
                              "100001111",      --address 335
                              "001000000",      --address 336
                              "010100001",      --address 337
                              "100000010",      --address 338
                              "101000011",      --address 339
                              "110000100",      --address 340
                              "111000101",      --address 341
                              "111100101",      --address 342
                              "111100110",      --address 343
                              "111100110",      --address 344
                              "111100111",      --address 345
                              "111100111",      --address 346
                              "111101000",      --address 347
                              "111101000",      --address 348
                              "111101000",      --address 349
                              "111101000",      --address 350
                              "111101001",      --address 351
                              "000000000",      --address 352
                              "000100010",      --address 353
                              "001100100",      --address 354
                              "001100110",      --address 355
                              "010001001",      --address 356
                              "010001100",      --address 357
                              "011001111",      --address 358
                              "011001111",      --address 359
                              "011101111",      --address 360
                              "011001111",      --address 361
                              "011101111",      --address 362
                              "011101111",      --address 363
                              "100001111",      --address 364
                              "100001111",      --address 365
                              "100001111",      --address 366
                              "100001111",      --address 367
                              "001000000",      --address 368
                              "010100001",      --address 369
                              "100000010",      --address 370
                              "101100011",      --address 371
                              "110000100",      --address 372
                              "111000101",      --address 373
                              "111100101",      --address 374
                              "111100110",      --address 375
                              "111100111",      --address 376
                              "111100111",      --address 377
                              "111101000",      --address 378
                              "111101000",      --address 379
                              "111101000",      --address 380
                              "111101001",      --address 381
                              "111101001",      --address 382
                              "111101001",      --address 383
                              "000000000",      --address 384
                              "001000010",      --address 385
                              "001100100",      --address 386
                              "001100110",      --address 387
                              "010101001",      --address 388
                              "011001100",      --address 389
                              "011001111",      --address 390
                              "011101111",      --address 391
                              "011001111",      --address 392
                              "100001111",      --address 393
                              "100001111",      --address 394
                              "011101111",      --address 395
                              "100001111",      --address 396
                              "100101111",      --address 397
                              "100101111",      --address 398
                              "100101111",      --address 399
                              "001000000",      --address 400
                              "010100001",      --address 401
                              "100000010",      --address 402
                              "101100011",      --address 403
                              "110000100",      --address 404
                              "111000101",      --address 405
                              "111100110",      --address 406
                              "111100110",      --address 407
                              "111100111",      --address 408
                              "111100111",      --address 409
                              "111101000",      --address 410
                              "111101000",      --address 411
                              "111101001",      --address 412
                              "111101001",      --address 413
                              "111101001",      --address 414
                              "111101010",      --address 415
                              "000000000",      --address 416
                              "001000010",      --address 417
                              "001100100",      --address 418
                              "010000110",      --address 419
                              "010001000",      --address 420
                              "010101011",      --address 421
                              "011001111",      --address 422
                              "011001111",      --address 423
                              "011101111",      --address 424
                              "100001111",      --address 425
                              "011101111",      --address 426
                              "100101111",      --address 427
                              "100101111",      --address 428
                              "100101111",      --address 429
                              "101001111",      --address 430
                              "100101111",      --address 431
                              "001000000",      --address 432
                              "010100001",      --address 433
                              "100000010",      --address 434
                              "101100011",      --address 435
                              "110100100",      --address 436
                              "111100101",      --address 437
                              "111100110",      --address 438
                              "111100110",      --address 439
                              "111100111",      --address 440
                              "111101000",      --address 441
                              "111101000",      --address 442
                              "111101001",      --address 443
                              "111101001",      --address 444
                              "111101010",      --address 445
                              "111101010",      --address 446
                              "111101010",      --address 447
                              "000000000",      --address 448
                              "001000010",      --address 449
                              "001100100",      --address 450
                              "010000110",      --address 451
                              "010001000",      --address 452
                              "011001011",      --address 453
                              "010101110",      --address 454
                              "011101111",      --address 455
                              "100001111",      --address 456
                              "100001111",      --address 457
                              "100001111",      --address 458
                              "100101111",      --address 459
                              "100001111",      --address 460
                              "100101111",      --address 461
                              "101001111",      --address 462
                              "101001111",      --address 463
                              "001000000",      --address 464
                              "010100001",      --address 465
                              "100000010",      --address 466
                              "101100011",      --address 467
                              "110100100",      --address 468
                              "111100101",      --address 469
                              "111100110",      --address 470
                              "111100111",      --address 471
                              "111100111",      --address 472
                              "111101000",      --address 473
                              "111101000",      --address 474
                              "111101001",      --address 475
                              "111101001",      --address 476
                              "111101010",      --address 477
                              "111101010",      --address 478
                              "111101011",      --address 479
                              "000000000",      --address 480
                              "001000010",      --address 481
                              "001100100",      --address 482
                              "010000110",      --address 483
                              "010101000",      --address 484
                              "010101010",      --address 485
                              "011001101",      --address 486
                              "011101111",      --address 487
                              "011101111",      --address 488
                              "011101111",      --address 489
                              "100101111",      --address 490
                              "100001111",      --address 491
                              "100101111",      --address 492
                              "101001111",      --address 493
                              "101101111",      --address 494
                              "101101111",      --address 495
                              "001000000",      --address 496
                              "010100001",      --address 497
                              "100000010",      --address 498
                              "101100011",      --address 499
                              "110100100",      --address 500
                              "111100101",      --address 501
                              "111100110",      --address 502
                              "111100111",      --address 503
                              "111100111",      --address 504
                              "111101000",      --address 505
                              "111101001",      --address 506
                              "111101001",      --address 507
                              "111101010",      --address 508
                              "111101010",      --address 509
                              "111101011",      --address 510
                              "111101011");     --address 511

end rom_package;
